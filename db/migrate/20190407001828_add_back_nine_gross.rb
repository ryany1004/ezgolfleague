class AddBackNineGross < ActiveRecord::Migration[5.2]
  def change
  	add_column :tournament_day_results, :back_nine_gross_score, :integer, default: 0
  end
end
