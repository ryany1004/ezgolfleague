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
    change_column :leagues, :dues_amount, :decimal
    
    remove_column :users, :has_paid
    
    drop_table :tournament_payments    
  end
end