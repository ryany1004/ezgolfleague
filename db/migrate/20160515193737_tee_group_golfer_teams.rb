class TeeGroupGolferTeams < ActiveRecord::Migration
  def change
    change_table :golfer_teams do |t|
      t.integer :tournament_group_id
    end

    add_index "golfer_teams", ["tournament_group_id"], name: "index_golfer_teams_tournament_group_id"
  end
end
