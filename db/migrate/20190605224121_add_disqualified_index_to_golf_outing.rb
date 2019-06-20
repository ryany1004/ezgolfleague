class AddDisqualifiedIndexToGolfOuting < ActiveRecord::Migration[5.2]
  def change
    add_index :golf_outings, :disqualified
  end
end
