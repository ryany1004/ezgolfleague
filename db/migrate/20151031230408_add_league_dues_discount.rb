class AddLeagueDuesDiscount < ActiveRecord::Migration
  def change
    change_table :league_memberships do |t|
      t.decimal :league_dues_discount, :default => 0
    end
    
    LeagueMembership.all.each do |m|
      m.league_dues_discount = 0
      m.save
    end
  end
end
