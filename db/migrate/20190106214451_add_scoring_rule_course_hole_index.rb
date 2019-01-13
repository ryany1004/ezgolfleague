class AddScoringRuleCourseHoleIndex < ActiveRecord::Migration[5.2]
  def change
  	add_index :scoring_rule_course_holes, :course_hole_id
  	add_index :scoring_rule_course_holes, :scoring_rule_id
  	add_index :scoring_rule_course_holes, [:course_hole_id, :scoring_rule_id], name: "scoring_holes_index"

  	add_index :scoring_rule_participations, :user_id
  	add_index :scoring_rule_participations, :scoring_rule_id
  	add_index :scoring_rule_participations, [:user_id, :scoring_rule_id], name: "scoring_participations_index"
  end
end