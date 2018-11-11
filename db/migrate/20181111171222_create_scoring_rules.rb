class CreateScoringRules < ActiveRecord::Migration[5.1]
  def change
    create_table :scoring_rules do |t|
    	t.string :type, null: false
      t.timestamps
    end

    add_index :scoring_rules, [:type]
    
		add_reference :scoring_rules, :tournament_day, foreign_key: true
		add_reference :payout_results, :scoring_rule, foreign_key: true
  end
end
