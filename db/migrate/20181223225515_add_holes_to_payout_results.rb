class AddHolesToPayoutResults < ActiveRecord::Migration[5.2]
  def change
  	add_column :payout_results, :scoring_rule_course_hole_id, :bigint
  	add_column :payout_results, :detail, :string
  end
end