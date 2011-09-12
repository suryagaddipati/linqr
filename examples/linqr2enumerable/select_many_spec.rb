require 'linqr'
describe "Select operators" do
  it "Compound From" do
    numbersA = [ 0, 2, 4, 5, 6, 8, 9 ]
    numbersB = [ 1, 3, 5, 7, 8 ]
    output = _{
      from a in_ numbersA
       from b in_ numbersB
       where a < b
       select [a, b ]
    }
    output.to_a.should = []
  end
end
