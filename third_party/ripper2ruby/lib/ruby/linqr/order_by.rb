require 'ruby/call'
module Ruby
  module Linqr
    class OrderBy < Ruby::Call
      def expressions
        descending?? (self.arguments[0...-1] << last_arg.first.key): self.arguments
      end

      def descending?
        last_arg.is_a? Ruby::Hash
      end

      def last_arg
        self.arguments.last.arg
      end
    end
  end
end
