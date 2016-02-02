class CreatePayoutResults < ActiveRecord::Migration
  def change
    create_table :payout_results do |t|
      t.integer :user_id
      t.integer :payout_id
      t.integer :flight_id
      t.integer :tournament_day_id
      t.decimal :amount
      t.float   :points
      t.timestamps null: false
    end
    
    add_index :payout_results, :user_id
    add_index :payout_results, :flight_id
    add_index :payout_results, :tournament_day_id
    add_index :payout_results, :payout_id
    
    Payout.all.each do |p|
      PayoutResult.create(user: p.user, payout: p, flight: p.flight, tournament_day: p.flight.tournament_day, amount: p.amount, points: p.points)
    end
    
    remove_column :payouts, :user_id
  end
end