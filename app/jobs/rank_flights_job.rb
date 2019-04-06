class RankFlightsJob < ApplicationJob
  def perform(tournament_day)
    tournament_day.scoring_rules.each do |rule|
    	tournament_day.flights.each do |flight|
    		Rails.logger.info { "RankFlightsJob #{flight.id} #{rule.id}" }

    		Flights::RankPosition.compute_rank(flight: flight, scoring_rule: rule)
    	end
    end
  end
end
