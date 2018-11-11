require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Golf Outing" do
  let(:league) { create(:league) }
  let(:league_season) { create(:league_season, league: league) }
  let(:tournament) { create(:tournament, league: league) }
  let(:tournament_day) { create(:tournament_day, tournament: tournament) }
  let(:tournament_group) { create(:tournament_group, tournament_day: tournament_day) }
  let(:golf_outing) { create(:golf_outing, tournament_group: tournament_group) }
  let(:generic_user) { build(:user) }

  it "#server_id" do 
    expect(generic_user).to respond_to(:server_id) 
  end

  it "#team_combined_name"

  it "#in_league?" do
    expect(golf_outing.in_league?(league)).to eq(true)
  end

  it "#disqualification_description"

  it "#disqualify"
end
