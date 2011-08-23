require 'linqr'
require 'active_record'
ENV['DB'] ||= "mysql"
database_yml = File.expand_path('../database.yml', __FILE__)
if File.exists?(database_yml)
  active_record_configuration = YAML.load_file(database_yml)[ENV['DB']]
  ActiveRecord::Base.establish_connection(active_record_configuration)
  ActiveRecord::Base.silence do
    ActiveRecord::Migration.verbose = false
    load(File.dirname(__FILE__) + '/schema.rb')
    load(File.dirname(__FILE__) + '/order.rb')
end
end
class Object
  # alias_method :try, :__send__
  def try(method, *args, &block)
    send(method, *args, &block) if respond_to?(method)
  end
end

describe "linqr" do
  it "simple binary expression" do 
    numbers = [ 5, 4, 1, 3, 9, 8, 6, 7, 2, 0 ]
    output =  _{ 
      from x
      in_ numbers
      where x > 1
      select x * 3
    }
    output.should == [15, 12, 9, 27, 24, 18, 21, 6]
  end
  it"a little complex binary expression"do 
    numbers = [ 5, 4, 1, 3, 9, 8, 6, 7, 2, 0 ]
    output =  _{ 
      from x
      in_ numbers
      where (x % 2) > 0
      select x
    }
    output.should == [ 5, 1, 3, 9, 7 ]
  end
  
  describe "ActiveRecord Provider" do
    before {
      ActiveRecord::Base.connection.execute "DELETE FROM Orders"  
      }


      it "should select from active-record" do
        Order.create(:name => "first")
        Order.create(:name => "second")
        second_order = Order.find(:all , :conditions => {:name => "second"})

        orders = Order.new #change this to order
        output =  _{ 
          from o
          in_  orders
          where o.name == "second"
          select o

        }
        output.should == second_order
      end
  end
end
