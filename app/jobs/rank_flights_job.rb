class RankFlightsJob < ApplicationJob
  def perform(tournament_day)
    tournament_day.flights.each do |f|
    	Flight.transaction do 
    		Rails.logger.info { "RankFlightsJob #{f.id}" }

    		Flights::RankPosition.compute_rank(f)
    	end
    end
  end
end
