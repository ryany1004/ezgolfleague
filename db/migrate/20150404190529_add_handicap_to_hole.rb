class AddHandicapToHole < ActiveRecord::Migration
  def change
    change_table :course_holes do |t|
      t.integer :mens_handicap, :default => 0
      t.integer :womens_handicap, :default => 0
    end
    
    CourseHole.all.each do |h|
      h.mens_handicap = 0
      h.womens_handicap = 0
      h.save
    end
  end
end
