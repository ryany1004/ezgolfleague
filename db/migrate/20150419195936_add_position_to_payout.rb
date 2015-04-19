class AddPositionToPayout < ActiveRecord::Migration
  def change
    change_table :payouts do |t|
      t.integer :sort_order, :default => 0
    end
  end
end
