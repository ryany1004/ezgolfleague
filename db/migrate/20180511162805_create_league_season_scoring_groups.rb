class CreateLeagueSeasonScoringGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :league_season_scoring_groups do |t|
    	t.integer :league_season_id
    	t.string :name
      t.timestamps
    end

		create_join_table :league_season_scoring_groups, :users do |t|
		  t.index [:league_season_scoring_group_id, :user_id], :name => 'scoring_group_index'
		end

		change_table :leagues do |t|
			t.boolean :allow_scoring_groups, default: false
		end

		League.all.each do |l|
			l.allow_scoring_groups = false
			l.save
		end
  end
end
