class MoveAdminCustomizedTeams < ActiveRecord::Migration
  def change
    change_table :tournament_days do |t|
      t.boolean :admin_has_customized_teams, :default => false
    end
    
    Tournament.all.each do |t|
      t.tournament_days.each do |day|
        day.admin_has_customized_teams = t.admin_has_customized_teams
        day.save
      end
    end
    
    remove_column :tournaments, :admin_has_customized_teams
  end
end
