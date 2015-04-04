class PickHolesForTournament < ActiveRecord::Migration
  def change
    create_table :course_holes_tournaments, id: false do |t|
      t.belongs_to :course_hole, index: true
      t.belongs_to :tournament, index: true
    end
  end
end
