require 'rails_helper'

describe "Logging into the system" do
  it "User can login" do
    user = create(:user)

    login_as(user, :scope => :user)
  end
end
