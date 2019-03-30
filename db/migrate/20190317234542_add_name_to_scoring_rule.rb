class AddNameToScoringRule < ActiveRecord::Migration[5.2]
  def change
  	add_column :scoring_rules, :custom_name, :string
  end
end
