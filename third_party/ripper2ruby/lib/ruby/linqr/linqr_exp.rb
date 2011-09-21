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
    end 
    
    class WhereClause < LinqrClause

    end

    class SelectClause < LinqrClause
      

    end


    class QueryBody
      #from-or-where-clausesopt   orderby-clauseopt   select-or-group-clause   into-clauseopt
      attr_accessor :from_clause, :where_clause , :select_clause , :into_clause 
      attr_accessor :group_by_clause, :order_by_clause

      def on_call(call)
          clause = case call.identifier.to_sym
                      when :from , :in_
                        @from_clause ||= FromClause.new
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
        @from_clause = FromClause.new
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

    end
  end
end
