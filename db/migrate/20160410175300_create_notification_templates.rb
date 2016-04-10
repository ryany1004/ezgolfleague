class CreateNotificationTemplates < ActiveRecord::Migration
  def change
    create_table :notification_templates do |t|
      t.integer :tournament_id
      t.integer :league_id
      t.string :title
      t.text :body
      t.timestamps null: false
    end

    add_index "notification_templates", ["tournament_id"], name: "index_tournament_id_on_notification_templates"
    add_index "notification_templates", ["league_id"], name: "index_league_id_on_notification_templates"
  end
end
