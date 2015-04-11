class CreateGolfOutings < ActiveRecord::Migration
  def change
    create_table :golf_outings do |t|
      t.integer :team_id, index: true
      t.integer :user_id, index: true
      t.timestamps null: false
    end
  end
end
