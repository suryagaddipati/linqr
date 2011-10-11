require 'linqr'
describe "Join Operations" do
  Listing = Struct.new(:name, :category)
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
end
