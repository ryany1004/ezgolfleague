class AddBlock < ActiveRecord::Migration[5.1]
  def change
  	 change_table :users do |t|
  	 	t.boolean :is_blocked, default: false
    end

    User.all.each do |u|
    	u.is_blocked = false
    	u.save
    end
  end
end
