require 'linqr'
describe "Join Operations" do
  Listing = Struct.new(:name, :category)
  TagLine = Struct.new(:tag_line, :category)
  it "Cross Join" do
    categories = [ "Beverages", "Condiments", "Vegetables", "Dairy Listings", "Seafood" ]
    products = [Listing.new("keyboard","computers"),Listing.new("pepsi","Beverages"),Listing.new("peppers","Vegetables"),Listing.new("coke","Beverages"),Listing.new("ice cream","Dairy Listings")]
    results = _{
      from c in_ categories
      join p in_ products on c == p.category
      select  category:  c, name:  p.name
    }
    results.to_a.count.should == 4
    results.to_a.collect(&:name).should == ["pepsi", "coke", "peppers", "ice cream"]
  end

  it "multi join" do
    categories = [ "Beverages", "Condiments", "Vegetables", "Dairy Listings", "Seafood" ]
    products = [Listing.new("keyboard","computers"),Listing.new("pepsi","Beverages"),Listing.new("peppers","Vegetables"),Listing.new("coke","Beverages"),Listing.new("ice cream","Dairy Listings")]
    tag_lines = [TagLine.new("People Work on these","computers"),TagLine.new("People Drink these","Beverages"),TagLine.new("People Eat These","Vegetables")]
    results = _{
      from c in_ categories
      join p in_ products on c == p.category
      join t in_ tag_lines on c == t.category
      select  category:  c, name:  p.name, tag_line: t.tag_line
    }
    results.to_a.count.should == 3
    results.to_a.collect(&:name).should == ["pepsi", "coke", "peppers"]
  end
end
