class AddDeliveredFlag < ActiveRecord::Migration
  def change
    add_column :notification_templates, :has_been_delivered, :boolean, default: false
  end
end
