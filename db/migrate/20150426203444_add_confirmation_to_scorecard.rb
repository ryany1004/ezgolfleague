class AddConfirmationToScorecard < ActiveRecord::Migration
  def change
    change_table :scorecards do |t|
      t.boolean :is_confirmed, :default => false
    end
  end
end
