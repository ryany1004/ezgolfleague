module Rankable
  extend ActiveSupport::Concern

  def combine_rankings(days)
    return days.first if days.count == 1
    
    Rails.logger.debug { "Combining Rankings" }
    
    last_day_flights = days.delete(days.last)

    last_day_flights.each do |last_day_flight|
      days.each do |day|
        day.each do |flight|
          last_day_flight[:players].each do |outer_player| #outer players
            flight[:players].each do |inner_player|
              if outer_player[:id] == inner_player[:id] #same player
                Rails.logger.debug { "Players Matched For #{outer_player[:id]}. Adding #{inner_player[:net_score]} to #{outer_player[:net_score]}" }
                
                outer_player[:net_score] += inner_player[:net_score]
                outer_player[:back_nine_net_score] += inner_player[:back_nine_net_score]
                outer_player[:gross_score] += inner_player[:gross_score]
                outer_player[:points] += inner_player[:points]
                
                outer_player[:par_related_gross_score] += inner_player[:par_related_gross_score]
                outer_player[:par_related_net_score] += inner_player[:par_related_net_score]
              end
            end
          end
        end
      end
      
      last_day_flight[:players].sort! { |x,y| x[:net_score] <=> y[:net_score] }
    end

    return last_day_flights
  end
  
end