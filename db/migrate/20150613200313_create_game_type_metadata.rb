class CreateGameTypeMetadata < ActiveRecord::Migration
  def change
    create_table :game_type_metadata do |t|
      t.references :course_hole, index: true
      t.references :scorecard, index: true
      t.references :golfer_team, index: true
      t.string :search_key, index: true
      t.string :string_value
      t.integer :integer_value
      t.timestamps null: false
    end
    
    add_index :game_type_metadata, [:scorecard_id, :search_key], :name => "scorecard_search_key_index"
  end
end