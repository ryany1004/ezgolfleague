class FixLeagueScoringGroups < ActiveRecord::Migration[5.1]
  def change
  	change_table :league_season_scoring_groups do |t|
			t.remove :flight_id
		end

		change_table :flights do |t|
			t.integer :league_season_scoring_group_id

			t.index [:league_season_scoring_group_id]
		end

		l = League.find(384)
		l.tournaments.each do |t|
			t.tournament_days.each do |d|
				d.flights.destroy_all
				d.create_scoring_group_flights
			end
		end
  end
end
