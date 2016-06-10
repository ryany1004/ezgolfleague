class DisqualifyGolfer < ActiveRecord::Migration
  def change
    change_table :golf_outings do |t|
      t.boolean :disqualified, default: false

      GolfOuting.update_all(disqualified: false)
    end
  end
end
