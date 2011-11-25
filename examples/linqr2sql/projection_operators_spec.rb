require 'linqr'
describe "Projection operators" do
  it "Simple 1" do 
    db = DB.new
    db.should_receive(:query).with("select p.name, p.age from people as p").and_return([])
    output =  _{ 
      from p
      in_ db.people
      select p.name, p.age
    }.to_a
  end
  it "select *" do 
    db = DB.new
    db.should_receive(:query).with("select p.* from people as p").and_return([])
    output =  _{ 
      from p
      in_ db.people
      select p
    }.to_a
  end
end
