class DisqualifyGolfer < ActiveRecord::Migration[4.2]
  def change
    change_table :golf_outings do |t|
      t.boolean :disqualified, default: false

      GolfOuting.update_all(disqualified: false)
    end
  end
end
