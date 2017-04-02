module FetchingTools

  class LeaderboardFetching

    def self.create_slimmed_down_leaderboard(tournament_day)
      complete_rankings = tournament_day.flights_with_rankings

      slimmed_rankings = []

      complete_rankings.each do |flight|
        flight[:players].each do |player|
          user = User.find(player[:id])
          group = tournament_day.tournament_group_for_player(user)

          slimmed_rankings << {id: player[:id].to_s, group: group.id.to_s, name: player[:name], net_score: player[:net_score].to_s, par_score: player[:par_related_net_score].to_s, place: player[:ranking].to_s}
        end
      end

      slimmed_rankings
    end

    def self.flights_with_rankings_could_be_combined(tournament_day, day_rankings)
      if tournament_day.tournament.tournament_days.count > 1 && tournament_day == tournament_day.tournament.last_day
        rankings = []

        tournament_day.tournament.tournament_days.each do |day|
          rankings << day.flights_with_rankings
        end

        Rails.logger.debug { "Attempting to Combine Rankings Across #{rankings.count} Days" }

        flights_with_rankings = tournament_day.tournament.combine_rankings(rankings)

        return flights_with_rankings
      else
        return day_rankings
      end
    end

  end

end
