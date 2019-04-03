class AddPlayersToLeague < ActiveRecord::Migration[5.2]
  def change
  	add_column :leagues, :league_estimated_players, :string
  end
end
