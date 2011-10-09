require 'linqr'
describe "Select Many" do
  it "Select from many collections" do
    numbersA = [ 0, 2, 4, 5, 6, 8, 9 ]
    numbersB = [ 1, 3, 5, 7, 8 ]
    output = _{
      from a in_ numbersA
       from b in_ numbersB
       where a < b
       select [a, b ]
    }
    output.to_a.should ==  [[0, 1], [0, 3], [0, 5], [0, 7], [0, 8], [2, 3], [2, 5], [2, 7], [2, 8], [4, 5], [4, 7], [4, 8], [5, 7], [5, 8], [6, 7], [6, 8]] 
  end

  it "From clause can be used any number of times" do
    numbersA = [ 0, 2, 4, 5, 6, 8, 9 ]
    numbersB = [ 1, 3, 5, 7, 8 ]
    numbersC = [2, 4]
    output = _{
      from a in_ numbersA
       from b in_ numbersB
       from c in_ numbersC
       where a < b && a > c
       select [a, b, c ]
    }
    output.to_a.should ==  [[4, 5, 2], [4, 7, 2], [4, 8, 2], [5, 7, 2], [5, 7, 4], [5, 8, 2], [5, 8, 4], [6, 7, 2], [6, 7, 4], [6, 8, 2], [6, 8, 4]]
  end
end
