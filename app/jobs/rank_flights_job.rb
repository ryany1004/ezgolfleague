class RankFlightsJob < ApplicationJob
  def perform(tournament_day)
    tournament_day.flights.each do |f|
      Flights::RankPosition.compute_rank(f)
    end
  end
end
