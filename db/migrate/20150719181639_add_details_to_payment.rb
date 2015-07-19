class AddDetailsToPayment < ActiveRecord::Migration
  def change
    change_table :payments do |t|
      t.string :payment_type #i.e. credit from xyz
      t.string :payment_source #i.e. credit card
      t.string :transaction_id
    end
    
    Tournament.all.each do |t|
      t.players.each do |p|
        Payment.create(tournament: t, payment_amount: t.dues_amount * -1.0, user: p, payment_source: "Tournament Dues")
        Payment.create(tournament: t, payment_amount: t.dues_amount, user: p, payment_source: "System Credit")
      end
    end
    
  end
end
