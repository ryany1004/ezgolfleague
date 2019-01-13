class AddCounterCacheToScoringRuleHoles < ActiveRecord::Migration[5.2]
  def change
  	add_column :scoring_rules, :scoring_rule_course_holes_count, :integer, default: 0

  	ScoringRule.all.each do |rule|
  		ScoringRule.reset_counters(rule.id, :scoring_rule_course_holes)
  	end
  end
end
