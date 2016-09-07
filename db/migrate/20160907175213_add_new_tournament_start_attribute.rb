class AddNewTournamentStartAttribute < ActiveRecord::Migration
  def change
    add_column :tournaments, :tournament_starts_at, :datetime

    Tournament.all.each do |t|
      t.tournament_starts_at = t.tournament_days.first.tournament_at unless t.tournament_days.first.blank?
      t.save
    end
  end
end
