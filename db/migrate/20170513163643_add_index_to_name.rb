class AddIndexToName < ActiveRecord::Migration[4.2]
  def change
    add_index :courses, :name
  end
end
