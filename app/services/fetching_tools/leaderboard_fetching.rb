module FetchingTools
  class LeaderboardFetching
    def self.create_slimmed_down_leaderboard(tournament_day)
      complete_rankings = tournament_day.flights_with_rankings

      slimmed_rankings = []

      complete_rankings.each do |flight|
        flight.tournament_day_results.each do |result|
          group = tournament_day.tournament_group_for_player(result.user)

          slimmed_rankings << { id: result.user.id.to_s,
                                group: group.id.to_s,
                                name: result.name,
                                net_score: result.net_score.to_s,
                                par_score: result.par_related_net_score.to_s,
                                place: result.rank.to_s }
        end
      end

      slimmed_rankings
    end

    def self.flights_with_rankings_could_be_combined(tournament_day, should_combine)
      if should_combine && tournament_day.tournament.tournament_days.count > 1 && tournament_day == tournament_day.tournament.last_day && tournament_day.has_scores?
        rankings = []

        tournament_day.tournament.tournament_days.each do |day|
          rankings << day.flights_with_rankings
        end

        Rails.logger.debug { "Attempting to Combine Rankings Across #{rankings.count} Days" }

        flights_with_rankings = tournament_day.tournament.combine_rankings(rankings)

        flights_with_rankings
      else
        tournament_day.tournament.tournament_days.first.flights_with_rankings
      end
    end
  end
end