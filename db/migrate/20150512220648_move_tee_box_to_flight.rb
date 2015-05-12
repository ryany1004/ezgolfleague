class MoveTeeBoxToFlight < ActiveRecord::Migration
  def change
    change_table :flights do |t|
      t.integer :course_tee_box_id
    end
    
    remove_column :tournaments, :mens_tee_box_id
    remove_column :tournaments, :womens_tee_box_id
  end
end
