require 'linqr'
describe "Projection operators" do
  it "Simple 1" do 
    numbers = [ 5, 4, 1, 3, 9, 8, 6, 7, 2, 0 ]
    output =  _{ 
      from n
      in_ numbers
      select n + 1
    }.to_a
    output.should == [6, 5, 2, 4, 10, 9, 7, 8, 3, 1]
  end

  it  "Simple 2" do
    Product = Struct.new(:name, :price)
    products = [Product.new("shoes", 1.75), Product.new("glasses", 55.55), Product.new("pencil", 5.20)]
    
    product_names = _{
      from p
      in_ products 
      select p.name
    }.to_a
    product_names.should == ["shoes","glasses","pencil"]
  end

  it  "Select - Transformation" do
    numbers = [ 5, 4, 1, 3, 9, 8, 6, 7, 2, 0 ]
    strings = [ "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" ]
    text_nums = _{
      from n
      in_ numbers
      select strings[n]
    }.to_a
    text_nums.should == ["five", "four", "one", "three", "nine", "eight", "six", "seven", "two", "zero"]
  end
  it "should return a thunk" do
    natural_numbers = Enumerator.new do |yielder|
      number = 1
      loop do
        yielder.yield number
        number += 1
      end
    end

    plus_ones = _{
      from n
      where n < 5
      in_ natural_numbers
      select n 
    }.take(4)
    
   plus_ones.to_a.should == [1,2,3,4] 

  end
end
