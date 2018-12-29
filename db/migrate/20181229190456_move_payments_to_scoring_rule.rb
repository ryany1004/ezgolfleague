class MovePaymentsToScoringRule < ActiveRecord::Migration[5.2]
  def change
  	add_column :payments, :scoring_rule_id, :bigint
  end
end
