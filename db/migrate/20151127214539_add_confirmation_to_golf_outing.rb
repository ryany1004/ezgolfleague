class AddConfirmationToGolfOuting < ActiveRecord::Migration
  def change
    add_column :golf_outings, :is_confirmed, :boolean, :default => false
    
    add_index :golf_outings, :is_confirmed
    
    GolfOuting.all.each do |go|
      go.is_confirmed = true
      go.save
    end
  end
end
