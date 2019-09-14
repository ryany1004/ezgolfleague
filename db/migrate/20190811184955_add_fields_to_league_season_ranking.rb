class AddFieldsToLeagueSeasonRanking < ActiveRecord::Migration[5.2]
  def change
    add_column :league_season_rankings, :average_score, :integer, default: 0
    add_column :league_seasons, :rankings_by_scoring_average, :boolean, default: false

    LeagueSeasonRanking.all.each do |r|
      r.update(average_score: 1)
    end

    LeagueSeason.all.order(created_at: :desc).each do |l|
      l.update(rankings_by_scoring_average: false)
    end
  end
end
