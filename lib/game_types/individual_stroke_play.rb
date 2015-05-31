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
    
    ##Handicap
    
    def handicap_allowance(user)
      golf_outing = self.tournament.golf_outing_for_player(user)
      course_handicap = user.course_handicap(self.tournament.course, golf_outing.course_tee_box)
    
      if golf_outing.course_tee_box.tee_box_gender == "Men"
        sorted_course_holes_by_handicap = self.tournament.course.course_holes.order("mens_handicap")
      else
        sorted_course_holes_by_handicap = self.tournament.course.course_holes.order("womens_handicap")
      end
        
      if !course_handicap.blank?    
        allowance = []
        while course_handicap > 0 do
          sorted_course_holes_by_handicap.each do |hole|
            existing_hole = nil
          
            allowance.each do |a|
              if hole == a[:course_hole]
                existing_hole = a
              end
            end
                    
            if existing_hole.blank?            
              existing_hole = {course_hole: hole, strokes: 0}
              allowance << existing_hole
            end
                    
            if course_handicap > 0
              existing_hole[:strokes] = existing_hole[:strokes] + 1
              course_handicap = course_handicap - 1
            end
          end
        end
      
        return allowance
      else
        return nil
      end
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