class AddDetailsToPayment < ActiveRecord::Migration
  def change
    change_table :payments do |t|
      t.string :payment_type #i.e. credit from xyz
      t.string :payment_method #i.e. credit card
      t.string :transaction_id
    end
  end
end
