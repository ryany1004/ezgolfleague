class UsersOnRules < ActiveRecord::Migration[5.1]
  def change
		create_join_table :scoring_rules, :users do |t|
			t.index [:scoring_rule_id, :user_id]
		end
  end
end
