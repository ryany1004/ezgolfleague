class CreateTournamentPayments < ActiveRecord::Migration
  def change
    create_table :tournament_payments do |t|
      t.integer :user_id
      t.integer :tournament_id
      t.decimal :payment_amount
      t.timestamps null: false
    end
  end
end
