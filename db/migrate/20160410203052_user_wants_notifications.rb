class UserWantsNotifications < ActiveRecord::Migration
  def change
    add_column :users, :wants_email_notifications, :boolean, default: true
    add_column :users, :wants_push_notifications, :boolean, default: true

    User.all.each do |u|
      u.wants_email_notifications = true
      u.wants_push_notifications = true

      u.save
    end
  end
end
