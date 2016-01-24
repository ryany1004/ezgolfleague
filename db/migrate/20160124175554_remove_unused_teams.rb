class RemoveUnusedTeams < ActiveRecord::Migration
  def change
    add_column :golf_outings, :tournament_group_id, :integer
    add_index :golf_outings, :tournament_group_id
    
    Team.all.each do |team|
      team.golf_outings.each do |outing|
        outing.tournament_group_id = team.tournament_group_id
        
        outing.save
      end
    end
    
    drop_table :teams
  end
end