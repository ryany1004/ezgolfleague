class FixHandicapType < ActiveRecord::Migration
  def up
    change_column :golf_outings, :course_handicap, :float
  end

  def down
    change_column :golf_outings, :course_handicap, :integer
  end
end
