class AddHandicapIndex < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.float :handicap_index, :default => 0
    end
  end
end
