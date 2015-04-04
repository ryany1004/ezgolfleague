class CourseRatingSlope < ActiveRecord::Migration
  def change
    change_table :courses do |t|
      t.float :rating, :default => 0
      t.integer :slope, :default => 0
    end
  end
end
