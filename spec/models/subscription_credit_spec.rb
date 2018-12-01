require 'rails_helper'

describe "Subscription Credit" do
  it "cost_per_golfer" do 
    expect(SubscriptionCredit.cost_per_golfer).to eq(10)
  end
end
