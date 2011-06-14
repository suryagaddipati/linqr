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
      attr_reader :from_generators
      def initialize
        @from_generators = []
      end
      def on_call(identifier)
        call = Ruby::Call.new(nil, nil, identifier)
        case identifier.to_sym
        when :from
          current_generator(call).from_call = call
        when :in_
          current_generator(call).in_call = call
        end
        call
      end

      def current_generator(call)
        unmatched = @from_generators.select{|g| g.in_call == nil || g.from_call == nil}
        if(unmatched.size == 0)
          fg =  FromGenerator.new(call)
          @from_generators << fg
          fg
        else 
          unmatched.first
        end
      end
    end 

    class FromGenerator
      #attr_accessor :identifier, :expression
      attr_accessor :in_call , :from_call
      def identifiers
        @from_call.arguments.collect(&:name)
      end
      def expression
        token =@in_call.arguments.first
        token.evaluate_source_name(SourceNameEvaluator.new)
      end
    end



    class LinqrExp
      attr_accessor :from_clause, :query_body
      def initialize
        @from_clause = FromClause.new
      end

      def on_call(identifier)
          case identifier.to_sym
          when :order_by
            Ruby::Linqr::OrderBy.new(nil, nil, identifier)
          when :group_by
            Ruby::Linqr::GroupBy.new(nil, nil, identifier)
          else
            @from_clause.on_call(identifier)
          end
      end
    end
  end
end
