class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.integer :tournament_group_id, index: true
      t.timestamps null: false
    end
  end
end
