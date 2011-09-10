require 'active_record'
require 'linqr'
require 'providers/active_record/activerecord_provider'
require 'spec_helper'
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
describe "ActiveRecord Provider" do
  before {
    ActiveRecord::Base.connection.execute "DELETE FROM Orders"  
  }


  it "should select from active-record" do
    Order.create(:name => "first")
    Order.create(:name => "second")
    second_order = Order.find(:all , :conditions => {:name => "second"})

    output =  _{ 
      from o
      in_  Order
      where o.name == "second"
      select o

    }
    output.should == second_order
  end
  describe "group_by" do
    it "should group by the attribute" do 
      Order.create(:name => "first")
      Order.create(:name => "second")
      Order.create(:name => "second")
      Order.create(:name => "third")

    expected_grouped_orders = Order.find(:all , :group => :name)

    grouped_by_name = _{
        from o 
        in_ Order
        group_by o.name   => :g
        select :name => g.key , :orders => g.values
      }
    grouped_by_name.collect(&:name).should == ["first", "second", "third"]
    end
  end
  
  describe "order by" do

   it "should order by the order by operator" do
      Order.create(:name => "berry")
      Order.create(:name => "apple")
      Order.create(:name => "peach")
      Order.create(:name => "cherry")

    expected_output = Order.find(:all , :order => :name).collect(&:name)

    ordered_names = _{
        from o 
        in_ Order
        order_by o.name
        select o.name
      }
    ordered_names.should == expected_output 
   end
  end

  describe "in" do
    it "should retrive all object" do
      Order.create(:name => "first")
      Order.create(:name => "second")
      Order.create(:name => "third")


    first_second = Order.find(:all , :conditions => {:name => ["second", "first"]})

      output =  _{ 
        from o
        in_ Order
        where ["second", "first"].member?(o.name)
        select o
      }
      output.should == first_second
    end
  end
end
