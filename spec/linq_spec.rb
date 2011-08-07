require 'linqr'
describe "linqr" do
  it "should apply selector" do 

    output =  _{ 
      from [1,2,3]
      where {|x| x > 1}
      selectr {|x| x*3 }
    }

    output.should == [6,9]
  end
end
