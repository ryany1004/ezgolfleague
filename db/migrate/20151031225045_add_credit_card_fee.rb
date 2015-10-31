class AddCreditCardFee < ActiveRecord::Migration
  def change
    change_table :leagues do |t|
      t.float :credit_card_fee_percentage, :default => 0.0
    end
    
    League.all.each do |m|
      m.credit_card_fee_percentage = 0
      m.save
    end
  end
end
