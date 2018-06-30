class AddDeletedAtToOthers < ActiveRecord::Migration[5.1]
  def change
    add_column :league_memberships, :deleted_at, :datetime
    add_index :league_memberships, :deleted_at

    add_column :payout_results, :deleted_at, :datetime
    add_index :payout_results, :deleted_at

    add_column :golf_outings, :deleted_at, :datetime
    add_index :golf_outings, :deleted_at

    add_column :payments, :deleted_at, :datetime
    add_index :payments, :deleted_at

    add_column :scorecards, :deleted_at, :datetime
    add_index :scorecards, :deleted_at

    add_column :scores, :deleted_at, :datetime
    add_index :scores, :deleted_at
  end
end