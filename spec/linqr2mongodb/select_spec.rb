require 'linqr2mongodb/mongo_spec_helper'
require 'linqr'
describe User do
  before { 
    User.delete_all
    User.create!(:login => "surya.gaddipati" , :email => "surya@gmail.com")
  }
  it "basic select" do
   output = _{
     from u in_ User
     select u
   }
   output.to_a.count.should == 1
   output.to_a.first.login.should == "surya.gaddipati"
  end
  
  it "where clause " do
   output = _{
     from u in_ User
     where u.login == "surya.gaddipati"
     select u
   }
   output.to_a.count.should == 1
   output.to_a.first.login.should == "surya.gaddipati"
  end
end
