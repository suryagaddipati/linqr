require 'ruby/linqr/linqr_clause'
module Ruby
  module Linqr
    class GroupByClause < LinqrClause
      def expression
        return first_arg.first.key if first_arg.is_a? Ruby::Hash
        @call
      end
      def grouping_var
        first_arg.first.value.first.to_sym
      end
      def arg
        @call.arguments.first.arg
      end
      def visit(visitor)
        visitor.visit_group_by(self)
      end
      def first_arg
        @call.arguments.first.arg
      end
    end
  end
end
