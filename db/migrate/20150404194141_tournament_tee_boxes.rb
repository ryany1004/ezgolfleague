class TournamentTeeBoxes < ActiveRecord::Migration
  def change
    change_table :tournaments do |t|
      t.string :mens_tee_box
      t.string :womens_tee_box
    end
  end
end
