class AddPaymentStuff < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.boolean :has_paid, :default => false
    end
    
    change_table :golf_outings do |t|
      t.boolean :has_paid, :default => false
    end
    
    change_table :tournaments do |t|
      t.decimal :dues_amount, :default => 0.0
    end
    
    change_table :leagues do |t|
      t.decimal :dues_amount, :default => 0.0
    end
  end
end
