class TournamentDaysCounterCache < ActiveRecord::Migration
  def change
    add_column :tournaments, :tournament_days_count, :integer, :default => 0
    
    ids = Set.new
    TournamentDay.all.each do |td|
      ids << td.tournament_id
    end
    
    ids.each do |tournament_id|
      Tournament.reset_counters(tournament_id, :tournament_days)
    end
  end
end