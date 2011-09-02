require 'linqr'
require 'spec_helper'

describe EnumerableExpessionEvaluator  do 

  describe "#visit_binary" do
    it "should invoke the operator" do 
    x = true
    y = false
    p = lambda{ x && y }

     #puts EnumerableExpessionEvaluator.new LinqrExp.new(p)
    end
  end
end
