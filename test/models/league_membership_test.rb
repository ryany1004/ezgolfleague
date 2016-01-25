require 'test_helper'

class LeagueMembershipTest < ActiveSupport::TestCase

  test "hunter is a member of brunswick" do
    hunter = User.where(email: "hunter@lastonepicked.com").first
    brunswick = League.where(name: "Brunswick").first
    
    assert true if hunter.leagues.include?(brunswick)
  end
  
end
