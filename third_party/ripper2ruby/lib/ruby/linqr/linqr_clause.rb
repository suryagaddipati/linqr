module Ruby
  module Linqr
    class LinqrClause
      attr_reader :call
      def on_call(call)
        @call = call
        true
      end
      def visit(visitor)
        if (@call.arguments.count == 1)
          @call.arguments.first.visit(visitor)
        else
          @call.arguments.inject([]){|out,arg| out << arg.visit(visitor); out }
        end
      end
    end
  end
end
