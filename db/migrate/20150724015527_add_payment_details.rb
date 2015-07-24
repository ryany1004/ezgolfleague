class AddPaymentDetails < ActiveRecord::Migration
  def change
    change_table :payments do |t|
      t.text :payment_details
    end
  end
end
