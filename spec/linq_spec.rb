require 'linqr'
describe "linqr" do
  it "should apply selector" do 
    output =  _{ 
      from x
      in_ [1,2,3]
      where x > 1
      select x * 3
    }
    output.should == [6,9]
  end
end
