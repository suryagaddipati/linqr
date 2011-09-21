require 'ruby/call'
module Ruby
  module Linqr
    class OrderByClause < LinqrClause 
      def expressions
        descending?? (@call.arguments[0...-1] << last_arg.first.key): @call.arguments
      end

      def descending?
        last_arg.is_a? Ruby::Hash
      end

      def last_arg
        @call.arguments.last.arg
      end
    end
  end
end
