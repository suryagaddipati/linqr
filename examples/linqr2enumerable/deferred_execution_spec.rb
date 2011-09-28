require 'linqr'
describe "Deferred execution" do
  it "lazy evaluation of infinite streams" do
    natural_numbers = Enumerator.new do |yielder|
      number = 1
      loop do
        yielder.yield number
        number += 1
      end
    end

  # plus_ones = _{
  #   from n
  #   where n < 5
  #   in_ natural_numbers
  #   select n 
  # }.take(4)
  # 
  #plus_ones.to_a.should == [1,2,3,4] 

  end

  it "Evaluation of results only when needed" do
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
