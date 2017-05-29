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

    expect(user.is_any_league_admin?).to eq(true)
  end

  it "Checking league membership" do
    user = create(:user)
    league = create(:league)

    user.leagues << league

    expect(user.is_member_of_league?(league)).to eq(true)
  end
end
