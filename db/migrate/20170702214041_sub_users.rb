class SubUsers < ActiveRecord::Migration[4.2]
  def change
    change_table :users do |t|
      t.integer :parent_id
    end
  end
end
