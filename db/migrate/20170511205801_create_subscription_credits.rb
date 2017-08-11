class CreateSubscriptionCredits < ActiveRecord::Migration[4.2]
  def change
    create_table :subscription_credits do |t|
      t.integer :league_id
      t.decimal :amount
      t.integer :golfer_count
      t.integer :tournament_count
      t.integer :tournaments_remaining
      t.string :transaction_id
      t.timestamps null: false
    end

    add_index :subscription_credits, :league_id

    change_table :tournaments do |t|
      t.integer :subscription_credit_id
    end

    add_index :tournaments, :subscription_credit_id

    change_table :leagues do |t|
      t.string :stripe_token
    end
  end
end
