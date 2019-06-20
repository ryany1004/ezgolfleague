class AddHandicapLockToGolfOuting < ActiveRecord::Migration[5.2]
  def change
    add_column :golf_outings, :handicap_lock, :boolean, default: false

    GolfOuting.update_all(handicap_lock: false)
  end
end
