class TournamentNotificationType < ActiveRecord::Migration
  def change
    add_column :notification_templates, :tournament_notification_action, :string
  end
end
