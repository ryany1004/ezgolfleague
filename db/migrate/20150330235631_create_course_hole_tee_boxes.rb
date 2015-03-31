class CreateCourseHoleTeeBoxes < ActiveRecord::Migration
  def change
    create_table :course_hole_tee_boxes do |t|
      t.integer :course_hole_id
      t.string :name
      t.string :description
      t.integer :yardage
      t.timestamps null: false
    end
  end
end
