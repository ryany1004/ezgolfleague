class RemoveTeamIdFromGolfOuting < ActiveRecord::Migration
  def change
    remove_column :golf_outings, :team_id
  end
end
