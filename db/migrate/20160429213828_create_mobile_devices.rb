class CreateMobileDevices < ActiveRecord::Migration
  def change
    create_table :mobile_devices do |t|
      t.integer :user_id
      t.string :device_identifier
      t.timestamps null: false
    end

    add_index :mobile_devices, :user_id
    add_index :mobile_devices, :device_identifier
  end
end
