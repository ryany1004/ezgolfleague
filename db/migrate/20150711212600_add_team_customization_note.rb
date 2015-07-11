class AddTeamCustomizationNote < ActiveRecord::Migration
  def change
    change_table :tournaments do |t|
      t.boolean :admin_has_customized_teams, :default => false
    end
    
    Tournament.all.each do |t|
      t.admin_has_customized_teams = false
      t.save
    end
  end
end
