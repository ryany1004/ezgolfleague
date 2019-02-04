class AddTeamToPayoutResults < ActiveRecord::Migration[5.2]
  def change
  	add_column :payout_results, :league_season_team_id, :bigint

  	add_index :payout_results, :league_season_team_id
  end
end
