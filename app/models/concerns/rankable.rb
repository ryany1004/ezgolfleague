module Rankable
  extend ActiveSupport::Concern
  include Rails.application.routes.url_helpers

  def flights_with_rankings
    ranked_flights = []
    
    self.flights.each do |f|
      ranked_flight = { flight_id: f.id, flight_number: f.flight_number, players: [] }
      
      f.users.each do |player|
        score = self.player_score(player)
      
        scorecard = self.primary_scorecard_for_user(player)
        scorecard_url = play_scorecard_path(scorecard)
        
        points = nil
        f.payouts.each do |payout|
          points = payout.points if payout.user == player
        end
      
        ranked_flight[:players] << { id: player.id, name: player.complete_name, score: score, scorecard_url: scorecard_url, points: points } if score > 0
      end
      
      ranked_flights << ranked_flight
    end
    
    return ranked_flights
  end
  
end