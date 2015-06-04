class EnhanceGolferTeams < ActiveRecord::Migration
  def change
    change_table :golfer_teams do |t|
      t.boolean :are_opponents, :default => false
      t.references :parent_team, index: true
    end
  end
end
