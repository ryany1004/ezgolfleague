class AddMoreCachedValuies < ActiveRecord::Migration
  def change
    change_table :tournament_day_results do |t|
      t.integer :front_nine_gross_score
    end
  end
end
