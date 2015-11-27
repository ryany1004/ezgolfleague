class MovePaymentsForLeagueDues < ActiveRecord::Migration
  def change
    add_column :payments, :league_season_id, :integer
    remove_column :payments, :league_id
  end
end
