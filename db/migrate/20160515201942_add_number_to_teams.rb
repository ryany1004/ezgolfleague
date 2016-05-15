class AddNumberToTeams < ActiveRecord::Migration
  def change
    change_table :golfer_teams do |t|
      t.string :team_number
    end
  end
end
