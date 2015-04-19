class AddMissingIndices < ActiveRecord::Migration
  def change
    add_index :course_hole_tee_boxes, :course_hole_id
    add_index :course_holes, :course_id
    add_index :course_tee_boxes, :course_id
    add_index :league_memberships, :league_id
    add_index :league_memberships, :user_id
    add_index :scores, :course_hole_id
    add_index :tournaments, :league_id
    add_index :tournaments, :course_id
  end
end