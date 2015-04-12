class SelectedLeagueUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.integer :current_league_id
    end
  end
end
