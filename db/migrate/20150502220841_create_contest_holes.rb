class CreateContestHoles < ActiveRecord::Migration
  def change
    create_table :contest_holes do |t|
      t.integer :contest_id
      t.integer :course_hole_id
      t.timestamps null: false
    end
  end
end
