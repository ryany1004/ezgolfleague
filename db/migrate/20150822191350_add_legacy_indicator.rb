class AddLegacyIndicator < ActiveRecord::Migration
  def change
    change_table :tournament_days do |t|
      t.boolean :data_was_imported, :default => false
    end
    
    TournamentDay.all.each do |d|
      d.data_was_imported = true
      d.save
    end
  end
end
