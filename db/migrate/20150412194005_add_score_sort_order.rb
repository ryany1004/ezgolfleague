class AddScoreSortOrder < ActiveRecord::Migration
  def change
    change_table :scores do |t|
      t.integer :sort_order, :default => 0
    end
  end
end
