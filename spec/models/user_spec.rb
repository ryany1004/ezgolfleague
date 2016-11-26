require 'rails_helper'

describe "Testing a user" do
  it "Checking league admin" do
    user = create(:user)
    league = create(:league)

    user.leagues << league

    membership = user.league_memberships.first
    membership.is_admin = true
    membership.save

    user.is_any_league_admin?
  end

  it "Checking league membership" do
    user = create(:user)
    league = create(:league)

    user.leagues << league

    user.is_member_of_league?(league)
  end
end
