class AddRegisteredBy < ActiveRecord::Migration[5.1]
  def change
  	change_table :golf_outings do |t|
  	 	t.string :registered_by
    end
  end
end
