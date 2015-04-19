class ConvertTournamentToTeeBox < ActiveRecord::Migration
  def change
    change_table :tournaments do |t|
      t.integer :mens_tee_box_id
      t.integer :womens_tee_box_id
    end
    
    remove_column :tournaments, :mens_tee_box
    remove_column :tournaments, :womens_tee_box
  end
end
