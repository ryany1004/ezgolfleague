class CreatePayouts < ActiveRecord::Migration
  def change
    create_table :payouts do |t|
      t.integer :flight_id, index: true
      t.integer :user_id
      t.decimal :amount
      t.float :points
      t.timestamps null: false
    end
  end
end
