class LeagueSeasonRanking < ApplicationRecord
  include Servable

  belongs_to :league_season_ranking_group, inverse_of: :league_season_rankings, touch: true
  belongs_to :user, optional: true
  belongs_to :league_season_team, optional: true

  def name
    if league_season_team.present?
      league_season_team.name
    else
      user.complete_name
    end
  end
end
