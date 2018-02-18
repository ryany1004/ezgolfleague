class RemoveTournamentRemaining < ActiveRecord::Migration[5.1]
  def change
  	remove_column :subscription_credits, :tournaments_remaining
  end
end
