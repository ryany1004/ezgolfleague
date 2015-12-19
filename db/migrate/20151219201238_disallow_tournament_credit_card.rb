class DisallowTournamentCreditCard < ActiveRecord::Migration
  def change
    add_column :tournaments, :allow_credit_card_payment, :boolean, :default => true
    
    Tournament.all.each do |t|
      t.allow_credit_card_payment = true
      t.save
    end
  end
end
