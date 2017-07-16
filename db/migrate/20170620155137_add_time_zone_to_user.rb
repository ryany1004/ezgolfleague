class AddTimeZoneToUser < ActiveRecord::Migration[4.2]
  def change
    change_table :users do |t|
      t.string :time_zone, default: "Pacific Time (US & Canada)"
    end

    User.all.each do |u|
      u.time_zone = "Pacific Time (US & Canada)"
      u.save
    end
  end
end
