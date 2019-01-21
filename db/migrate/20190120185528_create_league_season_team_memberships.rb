class CreateLeagueSeasonTeamMemberships < ActiveRecord::Migration[5.2]
  def change
    create_table :league_season_team_memberships do |t|
    	t.bigint :league_season_team_id
    	t.bigint :user_id
      t.timestamps
    end

    add_index :league_season_team_memberships, :league_season_team_id
    add_index :league_season_team_memberships, :user_id
  end
end
