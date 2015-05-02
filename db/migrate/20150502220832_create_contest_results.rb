class CreateContestResults < ActiveRecord::Migration
  def change
    create_table :contest_results do |t|
      t.integer :contest_id
      t.integer :contest_hole_id
      t.integer :winner_id
      t.string :result_value
      t.decimal :payout_amount
      t.timestamps null: false
    end
  end
end
