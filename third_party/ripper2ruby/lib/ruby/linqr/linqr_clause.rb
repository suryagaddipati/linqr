module Ruby
  module Linqr
    class LinqrClause
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
