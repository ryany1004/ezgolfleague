class TournamentGameType < ActiveRecord::Migration
  def change
    change_table :tournaments do |t|
      t.integer :game_type_id, :default => 1
    end
  end
end
