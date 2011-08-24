require 'linqr'
require 'spec_helper'
describe "linqr" do
  it "simple binary expression" do 
    numbers = [ 5, 4, 1, 3, 9, 8, 6, 7, 2, 0 ]
    output =  _{ 
      from x
      in_ numbers
      where x > 1
      select x * 3
    }
    output.should == [15, 12, 9, 27, 24, 18, 21, 6]
  end
  it"a little complex binary expression"do 
    numbers = [ 5, 4, 1, 3, 9, 8, 6, 7, 2, 0 ]
    output =  _{ 
      from x
      in_ numbers
      where (x % 2) > 0
      select x
    }
    output.should == [ 5, 1, 3, 9, 7 ]
  end
  it"compound 'or'  binary expression"do 
    numbers = [ 5, 4, 1, 3, 9, 8, 6, 7, 2, 0 ]
    output =  _{ 
      from x
      in_ numbers
      where (x == 3 ||  x == 5 || x == 8) && ( x % 2) == 0
      select x
    }
    output.should == [8]
  end
  it"compound 'and'  binary expression"do 
    numbers = [ 5, 4, 1, 3, 9, 8, 6, 7, 2, 0 ]
    output =  _{ 
      from x
      in_ numbers
      where x > 3 && x <= 5
      select x.to_s
    }
    output.should == [ '5','4']
  end

  it "query associative array" do
    hash = {:a => 1 , :b => 2 , :c => 3}
    output = _{
      from k,v
      in_ hash
      where v == 3
      select k
    }
    output.should == [:c]
  end
end
