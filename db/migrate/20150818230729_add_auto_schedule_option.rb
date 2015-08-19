class AddAutoScheduleOption < ActiveRecord::Migration
  def change
    change_table :tournaments do |t|
      t.integer :auto_schedule_for_multi_day, :default => 1
    end
    
    Tournament.all.each do |t|
      t.auto_schedule_for_multi_day == 1
      t.save
    end
  end
end
