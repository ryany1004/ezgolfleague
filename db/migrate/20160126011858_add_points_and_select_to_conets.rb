class AddPointsAndSelectToConets < ActiveRecord::Migration
  def change
    add_column :contests, :overall_winner_points, :integer, :default => 0
  end
end