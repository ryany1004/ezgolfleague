class AddLeagueExtraInfo < ActiveRecord::Migration[4.2]
  def change
    change_table :leagues do |t|
      t.boolean :show_in_search, default: true
      t.string :league_description
      t.string :contact_name
      t.string :contact_phone
      t.string :contact_email
      t.string :location

      League.update_all(show_in_search: true)
    end
  end
end
