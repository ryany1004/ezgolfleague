class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.integer :scorecard_id, index: true
      t.integer :course_hole_id
      t.integer :strokes, :default => 0
      t.timestamps null: false
    end
  end
end
