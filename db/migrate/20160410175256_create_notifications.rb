class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :notification_template_id
      t.integer :user_id
      t.string :title
      t.text :body
      t.boolean :is_read, default: false
      t.timestamps null: false
    end

    add_index "notifications", ["notification_template_id"], name: "index_notification_template_id_on_notifications"
    add_index "notifications", ["user_id"], name: "index_user_id_on_notifications"
  end
end
