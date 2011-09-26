require 'linqr'
describe "Deffered execution" do
  it "should return a thunk" do
    natural_numbers = Enumerator.new do |yielder|
      number = 1
      loop do
        yielder.yield number
        number += 1
      end
    end

#   plus_ones = _{
#     from n
#     where n < 5
#     in_ natural_numbers
#     select n 
#   }.take(4)
#   
#  plus_ones.to_a.should == [1,2,3,4] 

  end

  it "should calculate the results only when asked for" do
    numbers = [ 5, 4, 1, 3, 9, 8, 6, 7, 2, 0 ]
    output =  _{ 
      from n
      in_ numbers
      select n + 1
    }
    numbers = [5,8,9]
    output.to_a.should == [6,9,10]
  end
end
