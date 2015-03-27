class AddAttributesToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.boolean :is_super_user, :default => false
    end
    
    User.all.each do |u|
      u.is_super_user = true
      u.save
    end
  end
end
