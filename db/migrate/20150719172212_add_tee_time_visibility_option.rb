class AddTeeTimeVisibilityOption < ActiveRecord::Migration
  def change
    change_table :tournaments do |t|
      t.boolean :show_players_tee_times, :default => false
    end
    
    Tournament.all.each do |t|
      t.show_players_tee_times = true
      t.save
    end
  end
end