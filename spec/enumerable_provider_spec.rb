require 'linqr'
require 'spec_helper'
describe "linqr" do
  it "simple binary expression" do 
    numbers = [ 5, 4, 1, 3, 9, 8, 6, 7, 2, 0 ]
    output =  __{ 
      from x
      in_ numbers
      where x > 1
      select x * 3
    }
    output.should == [15, 12, 9, 27, 24, 18, 21, 6]
  end
  it"a little complex binary expression"do 
    numbers = [ 5, 4, 1, 3, 9, 8, 6, 7, 2, 0 ]
    output =  __{ 
      from x
      in_ numbers
      where (x % 2) > 0
      select x
    }
    output.should == [ 5, 1, 3, 9, 7 ]
  end
  it"compound 'or'  binary expression"do 
    numbers = [ 5, 4, 1, 3, 9, 8, 6, 7, 2, 0 ]
    output =  __{ 
      from x
      in_ numbers
      where (x == 3 ||  x == 5 || x == 8) && ( x % 2) == 0
      select x
    }
    output.should == [8]
  end
  it"compound 'and'  binary expression"do 
    numbers = [ 5, 4, 1, 3, 9, 8, 6, 7, 2, 0 ]
    output =  __{ 
      from x
      in_ numbers
      where x > 3 && x <= 5
      select x.to_s
    }
    output.should == [ '5','4']
  end

  it "query associative array" do
    hash = {:a => 1 , :b => 2 , :c => 3}
    output = __{
      from k,v
      in_ hash
      where v == 3
      select k
    }
    output.should == [:c]
  end

  it  "should work with models" do
    Product = Struct.new(:name, :price)
    products = [Product.new("shoes", 1.75), Product.new("glasses", 55.55), Product.new("pencil", 5.20)]
    
    cheap_product_names = __{
      from p
      in_ products 
      where p.price < 10
      select p.name
    }

    cheap_product_names.should == ["shoes","pencil"]
  end

  it "select into anonymous types" do
    Product = Struct.new(:name, :price)
    products = [Product.new("shoes", 1.75), Product.new("glasses", 55.55), Product.new("pencil", 5.20)]
    
    cheap_product_names = __{
      from p
      in_ products 
      where p.price < 10
      select :name => "Cheap - #{p.name}" , :new_price => p.price + 10
    }
    
    cheap_product_names.collect(&:name).should == ["Cheap - shoes","Cheap - pencil"]
    cheap_product_names.collect(&:new_price).should == [11.75, 15.20]

  end

  context "group by" do
    it "simple-1" do
      numbers = [ 5, 4, 1, 3, 9, 8, 6, 7, 2, 0 ]
      number_groups = __{
        from n 
        in_ numbers
        where n > 3 && n < 100
        group_by n % 5  => g
        select remainder: g.key , values: g.values
      }

      number_groups.collect(&:remainder).should == [0, 4, 3, 1, 2]
    end
  end

end
