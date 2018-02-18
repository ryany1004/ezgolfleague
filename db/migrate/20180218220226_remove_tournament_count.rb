class RemoveTournamentCount < ActiveRecord::Migration[5.1]
  def change
  	remove_column :subscription_credits, :tournament_count
  end
end
