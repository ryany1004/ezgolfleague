class AddFloatToMetadata < ActiveRecord::Migration
  def change
    change_table :game_type_metadata do |t|
      t.float :float_value
    end
  end
end
