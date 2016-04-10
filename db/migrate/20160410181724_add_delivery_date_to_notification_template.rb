class AddDeliveryDateToNotificationTemplate < ActiveRecord::Migration
  def change
    add_column :notification_templates, :deliver_at, :datetime
  end
end
