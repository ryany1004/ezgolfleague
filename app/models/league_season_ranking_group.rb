class LeagueSeasonRankingGroup < ApplicationRecord
  include Servable

  belongs_to :league_season, inverse_of: :league_season_ranking_groups, touch: true
  has_many :league_season_rankings, -> { order 'rank' }, inverse_of: :league_season_ranking_group, dependent: :destroy

  def displayable_league_season_rankings
    league_season_rankings
  end
end
