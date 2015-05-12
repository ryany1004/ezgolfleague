class TeeBoxGender < ActiveRecord::Migration
  def change
    change_table :course_tee_boxes do |t|
      t.string :tee_box_gender, :default => "Men"
    end
  end
end
