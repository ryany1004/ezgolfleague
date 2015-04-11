class CreateScorecards < ActiveRecord::Migration
  def change
    create_table :scorecards do |t|
      t.integer :golf_outing_id, index: true
      t.timestamps null: false
    end
  end
end
