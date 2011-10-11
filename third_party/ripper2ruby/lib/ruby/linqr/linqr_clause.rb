module Ruby
  module Linqr
    class LinqrClause
      attr_reader :call
      def on_call(call)
        @call = call
        true
      end
      def visit(visitor)
        @call.arguments.first.visit(visitor)
      end
    end
  end
end
