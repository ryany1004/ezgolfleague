class AddDqToScoringRuleParticipation < ActiveRecord::Migration[5.2]
  def change
  	add_column :scoring_rule_participations, :disqualified, :boolean, default: false

  	ScoringRuleParticipation.all.each do |s|
  		s.disqualified = false
  		s.save
  	end
  end
end
