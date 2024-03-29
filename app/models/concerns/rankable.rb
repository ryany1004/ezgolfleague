module Rankable
  extend ActiveSupport::Concern

  def combine_rankings(days)
    return days.first if days.count == 1

    Rails.logger.info { 'Combining Rankings' }

    last_day_flights = days.delete(days.last)

    last_day_flights.each do |last_day_flight|
      days.each do |day|
        day.each do |flight|
          last_day_flight.tournament_day_results.each do |outer_result| # outer result
            flight.tournament_day_results.each do |inner_result|
              if outer_result.combinable?(inner_result) # same result
                Rails.logger.info { "Players Matched For #{outer_result.name} #{outer_result.id}. Adding #{inner_result.net_score} to #{outer_result.net_score}" }

                outer_result.net_score += inner_result.net_score
                outer_result.back_nine_net_score += inner_result.back_nine_net_score
                outer_result.gross_score += inner_result.gross_score
                outer_result.par_related_gross_score += inner_result.par_related_gross_score
                outer_result.par_related_net_score += inner_result.par_related_net_score
              else
                Rails.logger.debug { "Could not combine #{outer_result.name} and #{inner_result.name}" }
              end
            end
          end
        end
      end

      last_day_flight.tournament_day_results.sort_by(&:par_related_net_score) if last_day_flight.tournament_day_results.present?
    end

    last_day_flights
  end
end
