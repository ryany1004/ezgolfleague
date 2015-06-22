class AddPointsToContestResults < ActiveRecord::Migration
  def change
    change_table :contest_results do |t|
      t.integer :points, :default => 0
    end
  end
end
