class OverUnderPar < ActiveRecord::Migration
  def change
    change_table :tournament_day_results do |t|
      t.integer :par_related_net_score
      t.integer :par_related_gross_score
    end
  end
end
