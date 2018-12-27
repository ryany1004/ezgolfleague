class CreateScoringRuleCourseHoles < ActiveRecord::Migration[5.2]
  def change
    create_table :scoring_rule_course_holes do |t|
    	t.bigint :course_hole_id
    	t.bigint :scoring_rule_id
      t.timestamps
    end
  end
end
