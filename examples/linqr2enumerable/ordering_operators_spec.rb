require 'linqr'
require 'spec_helper'
describe "order by" do
  Item = Struct.new(:name , :price, :discount_price)
  it "should order by the order by operator" do
    words = [ "cherry", "apple", "blueberry" ]
    sorted_words = __{
      from word in_ words
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
  it "then-by-descending" do
    products = [Item.new("bag", 9.00,5.00),Item.new("shoes", 5.00,2.00), Item.new("apple", 5.00,4.00), Item.new("cup", 25.00,14.00)]
     __{
      from p 
      in_ products
      order_by  p.price, p.discount_price
      select p
    }.collect(&:name).should == ["shoes","apple", "bag", "cup"] 
  end

  it "then-by" do
    products = [Item.new("bag", 9.00,5.00),Item.new("apple", 5.00,2.00), Item.new("shoes", 5.00,4.00), Item.new("cup", 25.00,5.00)]
     __{
      from p 
      in_ products
      order_by  p.price, p.discount_price => descending
      select p
    }.collect(&:name).should == ["cup","bag","shoes","apple"] 
  end
end
