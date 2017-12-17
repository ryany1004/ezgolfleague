module LoginHelpers
  def login_user
    user = FactoryBot.create(:user)
    league = FactoryBot.create(:league)
    league_membership = FactoryBot.create(:league_membership, league: league, user: user, is_admin: true)

    user
  end
end

RSpec.configure do |c|
  c.include LoginHelpers
end
