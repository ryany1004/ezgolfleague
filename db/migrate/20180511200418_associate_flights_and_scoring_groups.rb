class AssociateFlightsAndScoringGroups < ActiveRecord::Migration[5.1]
  def change
		change_table :league_season_scoring_groups do |t|
			t.integer :flight_id
		end
  end
end
