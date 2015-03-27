class CreateLeagueMemberships < ActiveRecord::Migration
  def change
    create_table :league_memberships do |t|
      t.integer :league_id
      t.integer :user_id
      t.boolean :is_admin, default: false
      t.timestamps null: false
    end
  end
end
