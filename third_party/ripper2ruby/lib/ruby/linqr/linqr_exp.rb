=begin
  query-expression:
    from-clause   query-body
  from-clause:
    from   from-generators
  from-generators:
    from-generator
  from-generators   ,   from-generator
  from-generator:
    identifier   in   expression
  query-body:
    from-or-where-clausesopt   orderby-clauseopt   select-or-group-clause   into-clauseopt
  from-or-where-clauses:
    from-or-where-clause
  from-or-where-clauses   from-or-where-clause
  from-or-where-clause:
    from-clause
  where-clause
  where-clause:
    where   boolean-expression
  orderby-clause:
    orderby   ordering-clauses
  ordering-clauses:
    ordering-clause
  ordering-clauses   ,   ordering-clause
  ordering-clause:
    expression    ordering-directionopt
  ordering-direction:
    ascending
  descending
  select-or-group-clause:
    select-clause
  group-clause
  select-clause:
    select   expression
  group-clause:
    group   expression   by   expression
  into-clause:
    into   identifier   query-body
=end
module Ruby
  module Linqr
    class FromClause
      attr_reader :from_call
      def initialize(in_clause= nil)
        @in_call = in_clause.call
      end
      def on_call(call)
        unless(complete =  @from_call && @in_call)
          case call.identifier.to_sym
          when :from
            @from_call = call
          when :in_
            @in_call = call
          end
        end 
        complete
      end

      def identifiers
        @from_call.arguments.collect(&:name).collect(&:to_sym)
      end
      def expression
        token =@in_call.arguments.first
        token.evaluate_source_name(SourceNameEvaluator.new)
      end
       def complete?
         @from_call && @in_call
       end
    end 
    
    class WhereClause < LinqrClause

      def visit(visitor)
        visitor.visit_where_clause(self)
      end

      def expression
        @call.arguments.first
      end
    end

    class SelectClause < LinqrClause; end

    class InClause < LinqrClause; end

    
    class OnClause < LinqrClause
      def visit(visitor)
        visitor.visit_on_clause(self)
      end
      def lhs
        @call.arguments.first.arg.identifier
      end

      def rhs
        rhs = @call.arguments.first.arg.arguments.first.arg.arguments.first.arg
        rhs = rhs.clone
        rhs.arguments = nil
        rhs
        #@call.arguments.first.arg.arguments.first.arg.arguments.first
      end
      
      def group_join?
        @call.to_ruby.split("into").length > 1
      end

      def group_join_var
        @call.to_ruby.split("into")[1].to_sym
      end
    end


    class JoinClause < FromClause
      #join-clause ::= join itemName in srcExpr on keyExpr == keyExpr (into itemName)?
      attr_reader :on_clause
      def initialize(in_clause, on_clause)
        @on_clause = on_clause
        super in_clause
      end
      def on_call(call)
          case call.identifier.to_sym
          when :join
            @join_call = call
          when :in_
            @in_call = call
          end
      end

      def identifiers
        @join_call.arguments.collect(&:name).collect(&:to_sym)
      end

    end

    class QueryBody
      #query-body ::= join-clause* (from-clause join-clause* |
      #let-clause | where-clause)* orderby-clause? (select-clause |
      #groupby-clause) query-continuation?
      attr_accessor :from_clauses, :where_clause , :select_clause 
      attr_accessor :group_by_clause, :order_by_clause
      attr_accessor :join_clauses

      def on_call(call)
        clause = case call.identifier.to_sym
                 when :join
                   @join_clauses ||=[]
                   @join_clauses << JoinClause.new(@in_clause,@on_clause)
                   @join_clauses.last
                 when :on 
                   @on_clause = OnClause.new
                   @on_clause
                 when :from 
                   @from_clauses ||=[]
                   @from_clauses << FromClause.new(@in_clause)
                   @from_clauses.last
                 when :in_
                   @in_clause = InClause.new
                   @in_clause
                 when :select
                   @select_clause ||= SelectClause.new
                 when :where
                   @where_clause ||= WhereClause.new
                 when :order_by
                   @order_by_clause ||= OrderByClause.new
                 when :group_by
                   @group_by_clause ||= GroupByClause.new
                 end
         clause.on_call(call) unless clause.nil?
      end

    end

    class LinqrExp
      attr_accessor :from_clause, :query_body
      def initialize(binding)
        @from_clause = FromClause.new(InClause.new)
        @query_body = QueryBody.new
        @binding = binding
      end

      def on_call(identifier)
        call = Ruby::Call.new(nil, nil, identifier)
        @query_body.on_call(call) if( @from_clause.on_call(call))
        call
      end

      def source
        source_name = self.from_clause.expression
        @binding.eval(source_name)
      end

      def variable_val(name)
        @binding.eval(name)
      end
      def visit(visitor)
        visitor.visit_linqr_exp(self)
      end

    end
  end
end
