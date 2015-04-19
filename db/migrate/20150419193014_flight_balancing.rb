class FlightBalancing < ActiveRecord::Migration
  def change
    change_table :flights do |t|
      t.integer :lower_bound
      t.integer :upper_bound
    end
  end
end
