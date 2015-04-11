class AddMaxPlayersToGroup < ActiveRecord::Migration
  def change
    change_table :tournament_groups do |t|
      t.integer :max_number_of_players, :default => 4
    end
  end
end
