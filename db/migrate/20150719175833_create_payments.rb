class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer  "user_id"
      t.integer  "tournament_id"
      t.decimal  "payment_amount"
      t.integer :league_id

      t.timestamps null: false
      
      t.index :user_id
      t.index :tournament_id
      t.index :league_id
    end
    
    change_column :tournaments, :dues_amount, :decimal
    
    drop_table :tournament_payments
    
    Tournament.all.each do |t|
      t.players.each do |p|
        Payment.create(tournament: t, payment_amount: t.dues_amount * -1.0, user: p, payment_method: "Tournament Dues")
        Payment.create(tournament: t, payment_amount: t.dues_amount, user: p, payment_method: "System Credit")
      end
    end
    
  end
end