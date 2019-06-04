class AddPayoutResultSortingHint < ActiveRecord::Migration[5.2]
  def change
    add_column :payout_results, :sorting_hint, :integer
  end
end
