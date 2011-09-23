require 'linqr'
require 'spec_helper'
require 'providers/groupon/groupon_provider'

describe 'Groupon provider' do 

  it "should query groupon" do
    output =  _{ 
      from deal
      in_  GrouponDeals
      where deal.lat == 38.8339 && deal.lng == -104.821 
      select deal
    }
  end
end
