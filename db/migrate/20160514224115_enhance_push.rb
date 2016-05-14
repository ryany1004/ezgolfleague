class EnhancePush < ActiveRecord::Migration
  def change
    change_table :mobile_devices do |t|
      t.string :device_type
      t.string :environment_name
    end

    MobileDevice.all.each do |m|
      m.device_type = "iphone"
      m.environment_name = "production"
      m.save
    end
  end
end
