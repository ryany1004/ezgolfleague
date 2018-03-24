class AddScoreNotification < ActiveRecord::Migration[5.1]
  def change
   	change_table :scores do |t|
  	 	t.boolean :has_notified, default: false
    end

    Score.update_all has_notified: false
  end
end
