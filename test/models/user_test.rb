require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  test "hunter exists" do
    u = User.where(email: "hunter@lastonepicked.com").first
    
    assert_not_nil(u)
  end
  
end
