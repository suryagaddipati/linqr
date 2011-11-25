require 'linqr'
describe "Projection operators" do
  it "Simple 1" do 
    db = DB.new
    db.should_receive(:execute).with("select name from people")
    output =  _{ 
      from p
      in_ db.people
      select p.name
    }.to_a
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
end
