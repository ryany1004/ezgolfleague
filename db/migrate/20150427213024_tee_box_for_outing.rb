class TeeBoxForOuting < ActiveRecord::Migration
  def change
    change_table :golf_outings do |t|
      t.integer :course_tee_box_id
    end
  end
end
