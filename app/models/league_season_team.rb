class LeagueSeasonTeam < ApplicationRecord
  belongs_to :league_season
  has_many :tournament_day_results, dependent: :destroy, inverse_of: :league_season_team
  has_many :league_season_team_memberships, dependent: :destroy
  has_many :users, through: :league_season_team_memberships
  has_many :payout_results, dependent: :destroy, inverse_of: :league_season_team
  has_many :league_season_rankings, dependent: :destroy

  TEAM_NAME_STATIC_PLAYER_NAME = 'Players: '.freeze

  def should_update_team_name?
    name.include? TEAM_NAME_STATIC_PLAYER_NAME
  end

  def update_team_name
    name = TEAM_NAME_STATIC_PLAYER_NAME

    users.each do |u|
      name << u.short_name
      name << ' / ' if u != users.last
    end

    save
  end
end
