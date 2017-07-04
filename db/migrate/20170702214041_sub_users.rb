class SubUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.integer :parent_id
    end
  end
end
