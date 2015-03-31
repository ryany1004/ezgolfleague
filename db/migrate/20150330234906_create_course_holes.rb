class CreateCourseHoles < ActiveRecord::Migration
  def change
    create_table :course_holes do |t|
      t.integer :course_id
      t.integer :hole_number
      t.integer :par
      t.timestamps null: false
    end
  end
end
