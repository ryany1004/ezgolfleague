class CreateScoringRuleParticipations < ActiveRecord::Migration[5.2]
  def change
    create_table :scoring_rule_participations do |t|
    	t.bigint :user_id
    	t.bigint :scoring_rule_id
    	t.decimal :dues_paid, default: 0.0
      t.timestamps
    end
  end
end
