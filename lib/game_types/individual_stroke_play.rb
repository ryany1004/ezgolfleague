module GameTypes
  class IndividualStrokePlay < GameTypes::GameTypeBase
    include Rails.application.routes.url_helpers

    def display_name
      return "Individual Stroke Play"
    end
    
    def game_type_id
      return 1
    end

    def other_group_members(user)
      other_members = []
      
      group = self.tournament.tournament_group_for_player(user)
      group.teams.each do |team|
        team.golf_outings.each do |outing|
          other_members << outing.user if outing.user != user
        end
      end
      
      return other_members
    end
    
    def user_is_in_group?(user, tournament_group)
      tournament_group.teams.each do |team|
        team.golf_outings.each do |outing|
          return true if user == outing.user
        end
      end
      
      return false
    end
    
    ##Scoring

    def player_score(user)
      return nil if !self.tournament.includes_player?(user)

      total_score = 0
    
      handicap_allowance = self.tournament.handicap_allowance(user)

      scorecard = self.tournament.primary_scorecard_for_user(user)
      scorecard.scores.each do |score|
        hole_score = score.strokes
      
        handicap_allowance.each do |h|
          if h[:course_hole] == score.course_hole
            if h[:strokes] != 0
              hole_score = hole_score - h[:strokes]
            end
          end
        end
      
        total_score = total_score + hole_score
      end
    
      return total_score
    end

    def player_points(user)
      return nil if !self.tournament.includes_player?(user)
    
      points = 0
    
      self.tournament.flights.each do |f|
        f.payouts.each do |p|
          points = points + p.points if p.user == user
        end
      end
    
      return points
    end
    
    ##Ranking

    def flights_with_rankings
      ranked_flights = []
    
      self.tournament.flights.each do |f|
        ranked_flight = { flight_id: f.id, flight_number: f.flight_number, players: [] }
      
        f.users.each do |player|
          score = self.player_score(player)
      
          scorecard = self.tournament.primary_scorecard_for_user(player)
          scorecard_url = play_scorecard_path(scorecard)
        
          points = 0
          f.payouts.each do |payout|
            points = payout.points if payout.user == player
          end
      
          ranked_flight[:players] << { id: player.id, name: player.complete_name, score: score, scorecard_url: scorecard_url, points: points } if !score.blank? && score > 0
        end
        ranked_flight[:players].sort! { |x,y| y[:points] <=> x[:points] }
      
        ranked_flights << ranked_flight
      end
    
      return ranked_flights
    end

    def assign_payouts_from_scores
      self.tournament.flights.each do |f|
        player_scores = []
      
        f.users.each do |player|
          score = self.player_score(player)
      
          player_scores << {player: player, score: score}
        end
      
        player_scores.sort! { |x,y| x[:score] <=> y[:score] }
      
        Rails.logger.debug { "Flights: #{self.flights.count} | Users: #{f.users.count} | PS: #{player_scores.count} | Payouts: #{f.payouts.count}" }
      
        f.payouts.each_with_index do |p, i|
          if player_scores.count > i
            player = player_scores[i][:player]
        
            p.user = player
            p.save
          end
        end
      end
    end

  end
end