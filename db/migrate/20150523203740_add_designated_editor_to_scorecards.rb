class AddDesignatedEditorToScorecards < ActiveRecord::Migration
  def change
    change_table :scorecards do |t|
      t.integer :designated_editor_id
    end
  end
end
