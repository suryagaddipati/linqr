require 'linqr'
describe "linqr" do
  it "should apply selector" do 
    numbers = [ 5, 4, 1, 3, 9, 8, 6, 7, 2, 0 ]
    output =  _{ 
      from x
      in_ numbers
      where x > 1
      select x * 3
    }
    output.should == [15, 12, 9, 27, 24, 18, 21, 6]
  end
end
