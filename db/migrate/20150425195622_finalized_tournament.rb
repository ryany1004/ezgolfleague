class FinalizedTournament < ActiveRecord::Migration
  def change
    change_table :tournaments do |t|
      t.boolean :is_finalized, :default => false
    end
  end
end
