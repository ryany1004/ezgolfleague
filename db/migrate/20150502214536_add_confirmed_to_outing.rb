class AddConfirmedToOuting < ActiveRecord::Migration
  def change
    change_table :golf_outings do |t|
      t.boolean :confirmed, :default => false
    end
    
    GolfOuting.all.each do |g|
      g.confirmed = true
      g.save
    end
  end
end
