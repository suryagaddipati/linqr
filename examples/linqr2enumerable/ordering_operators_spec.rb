require 'linqr'
require 'spec_helper'
describe "order by" do

  it "should order by the order by operator" do
    words = [ "cherry", "apple", "blueberry" ]
    sorted_words = __{
      from word 
      in_ words
      order_by word
      select word
    }
    sorted_words.should ==  ["apple", "blueberry","cherry" ]
  end

  it "simple-2" do
    words = [ "cherry", "apple", "blueberry" ]
    sorted_words = __{
      from word 
      in_ words
      order_by word.length
      select word
    }
    sorted_words.should == ["apple", "cherry", "blueberry"]
  end
  
  it "descending" do
    doubles = [ 1.7, 2.3, 1.9, 4.1, 2.9 ]
    desc_doubles = __{
      from d 
      in_ doubles
      order_by  d => descending
      select d
    }
    desc_doubles.should == [4.1, 2.9, 2.3, 1.9, 1.7]

  end
end
