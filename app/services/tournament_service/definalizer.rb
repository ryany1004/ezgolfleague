module TournamentService
  module Definalizer
    extend self

    def call(tournament, clear_matchups = false)
      tournament.update(is_finalized: false)

      remove_league_season_team_matchup_lock(tournament) if clear_matchups
    end

    private

    def remove_league_season_team_matchup_lock(tournament)
      tournament.tournament_days.each do |day|
        day.league_season_team_tournament_day_matchups.each do |matchup|
          matchup.update(team_a_final_sort: nil)
          matchup.update(team_b_final_sort: nil)
        end
      end
    end
  end
end
