class AddHandicapToOuting < ActiveRecord::Migration
  def change
    change_table :golf_outings do |t|
      t.integer :course_handicap, :default => 0
    end
  end
end
