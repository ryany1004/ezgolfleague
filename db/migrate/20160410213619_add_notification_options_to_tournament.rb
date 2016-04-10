class AddNotificationOptionsToTournament < ActiveRecord::Migration
  def change
    add_column :notification_templates, :notify_on_tournament_finalization, :boolean, default: true
    add_column :notification_templates, :notify_tournament_unregistered_players_before_closing, :boolean, default: true
  end
end
