class AddStateToLeagueMembership < ActiveRecord::Migration
  def change
    change_table :league_memberships do |t|
      t.string :state
    end
  end
end
