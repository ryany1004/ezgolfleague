class LeagueSeasonRankingGroup < ApplicationRecord
	include Servable

	belongs_to :league_season, inverse_of: :league_season_ranking_groups, touch: true
	has_many :league_season_rankings, ->{ order 'rank' }, inverse_of: :league_season_ranking_group, dependent: :destroy

  #JSON

  def as_json(options={})
    super(
      :only => [:name],
      :methods => [:server_id],
      :include => {
        :league_season_rankings => {
          :only => [:points, :payouts, :rank],
          :methods => [:server_id, :name],
          :include => {
            :user => {
              :methods => [:server_id]
            }
          }
        }
      }
    )
  end

end
