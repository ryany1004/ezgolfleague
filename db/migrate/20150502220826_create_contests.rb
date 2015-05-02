class CreateContests < ActiveRecord::Migration
  def change
    create_table :contests do |t|
      t.integer :tournament_id
      t.string :name
      t.integer :contest_type
      t.integer :overall_winner_contest_result_id
      t.decimal :overall_winner_payout_amount
      t.timestamps null: false
    end
  end
end
