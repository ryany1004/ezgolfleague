module FetchingTools
  
  class LeaderboardFetching
    
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