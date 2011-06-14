require 'ruby/call'
module Ruby
  module Linqr
    class GroupBy < Ruby::Call
      def expression
        return self.arg.first.key if self.arg.is_a? Ruby::Hash
        self
      end
      def grouping_var
        self.arg.first.value.first.to_sym
      end
      def arg
        self.arguments.first.arg
      end
    end
  end
end
