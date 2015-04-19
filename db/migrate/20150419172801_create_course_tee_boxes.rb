class CreateCourseTeeBoxes < ActiveRecord::Migration
  def change
    create_table :course_tee_boxes do |t|
      t.integer :course_id
      t.string :name
      t.float :rating, :default => 0.0
      t.integer :slope, :default  => 0
      t.timestamps null: false
    end
    
    add_column :course_hole_tee_boxes, :course_tee_box_id, :integer
    
    remove_column :courses, :rating
    remove_column :courses, :slope
    remove_column :course_hole_tee_boxes, :name
  end
end