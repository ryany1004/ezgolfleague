class RemoveTournamentId < ActiveRecord::Migration[5.1]
  def change
  	remove_column :tournaments, :subscription_credit_id
  end
end
