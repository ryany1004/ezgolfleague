module LoginHelpers
  def login_user
    user = FactoryGirl.create(:user)
    league = FactoryGirl.create(:league)
    league_membership = FactoryGirl.create(:league_membership, league: league, user: user, is_admin: true)

    user
  end
end

RSpec.configure do |c|
  c.include LoginHelpers
end
