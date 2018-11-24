class CreateScoringRules < ActiveRecord::Migration[5.1]
  def change
    create_table :scoring_rules do |t|
    	t.string :type, null: false
      t.timestamps
    end

    add_index :scoring_rules, [:type]
    
		add_reference :scoring_rules, :tournament_day, index: true
		add_reference :payout_results, :scoring_rule, index: true
  end
end
