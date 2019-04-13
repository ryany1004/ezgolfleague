class AddDeletedAtIndexes < ActiveRecord::Migration[5.2]
  def change
  	add_index :tournament_days, :updated_at
  	add_index :tournaments, :updated_at
  	add_index :tournament_day_results, :updated_at
  	add_index :scoring_rules, :updated_at

  	add_index :tournament_day_results, [:user_id, :scoring_rule_id]
  end
end
