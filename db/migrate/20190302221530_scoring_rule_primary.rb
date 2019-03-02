class ScoringRulePrimary < ActiveRecord::Migration[5.2]
  def change
  	add_column :scoring_rules, :primary_rule, :boolean, default: false
		add_index :scoring_rules, :primary_rule

  	TournamentDay.all.each do |d|
  		rule = d.mandatory_scoring_rules.reorder('scoring_rule_course_holes_count DESC').limit(1).first
  		next if rule.blank?

  		rule.primary_rule = true
  		rule.save
  	end
  end
end
