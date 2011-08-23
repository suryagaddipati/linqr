require 'active_record'
require 'linqr'
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
