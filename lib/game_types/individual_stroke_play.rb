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
    
    ##Setup
    
    def can_be_played?
      return false if self.tournament.tournament_groups.count == 0
      return false if self.tournament.flights.count == 0
    
      self.tournament.players.each do |p|
        return false if self.tournament.flight_for_player(p) == nil
      end
    
      return true
    end
  
    def can_be_finalized?
      flight_payouts = 0
    
      self.tournament.flights.each do |f|
        flight_payouts += f.payouts.count
      end
    
      if flight_payouts == 0
        return false
      else
        return true
      end
    end
    
    ##Scoring
    
    def related_scorecards_for_user(user)
      other_scorecards = []
      
      self.tournament.other_group_members(user).each do |player|
        other_scorecards << self.tournament.primary_scorecard_for_user(player)
      end
      
      return other_scorecards
    end

    def player_score(user, use_handicap = true)
      return nil if !self.tournament.includes_player?(user)

      total_score = 0
    
      handicap_allowance = self.tournament.handicap_allowance(user)

      scorecard = self.tournament.primary_scorecard_for_user(user)
      scorecard.scores.each do |score|
        hole_score = score.strokes
      
        if use_handicap == true
          handicap_allowance.each do |h|
            if h[:course_hole] == score.course_hole
              if h[:strokes] != 0
                hole_score = hole_score - h[:strokes]
              end
            end
          end
        end

        total_score = total_score + hole_score
      end
    
      total_score = 0 if total_score < 0
    
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
          net_score = self.player_score(player, true)
          gross_score = self.player_score(player, false)
          
          scorecard = self.tournament.primary_scorecard_for_user(player)
          scorecard_url = play_scorecard_path(scorecard)
        
          points = 0
          f.payouts.each do |payout|
            points = payout.points if payout.user == player
          end
      
          ranked_flight[:players] << { id: player.id, name: player.complete_name, net_score: net_score, gross_score: gross_score, scorecard_url: scorecard_url, points: points } if !net_score.blank? && net_score > 0
        end
        ranked_flight[:players].sort! { |x,y| x[:net_score] <=> y[:net_score] }
      
        ranked_flights << ranked_flight
      end
    
      return ranked_flights
    end

  end
end