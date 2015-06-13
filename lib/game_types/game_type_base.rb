module GameTypes

  TEAMS_ALLOWED = "Allowed"
  TEAMS_REQUIRED = "Required"
  TEAMS_DISALLOWED = "Disallowed"
  
  VARIABLE = -1

  class GameTypeBase
    attr_accessor :tournament
    
    def self.available_types
      return [GameTypes::IndividualStrokePlay.new, GameTypes::IndividualMatchPlay.new, GameTypes::IndividualModifiedStableford.new, GameTypes::TwoManShamble.new]
    end
    
    def display_name
      return nil
    end
    
    def game_type_id
      return nil
    end
    
    ##Setup
    
    def can_be_played?
      return false
    end
    
    def can_be_finalized?
      return false
    end
    
    ##Group
    
    def other_group_members(user)
      return nil
    end
    
    def user_is_in_group?(user, tournament_group)
      return false
    end
    
    ##Teams
    
    def allow_teams
      return GameTypes::TEAMS_DISALLOWED
    end
    
    def show_teams?
      return false
    end
    
    def number_of_players_per_team
      return 0
    end
    
    def players_create_teams?
      return true
    end
    
    def show_team_scores_for_all_teammates?
      return true
    end
    
    def team_players_are_opponents?
      return false
    end
    
    ##Scoring
    
    def related_scorecards_for_user(user)
      return []
    end

    def player_score(user)
      return nil
    end
    
    def player_points(user)
      return nil
    end
    
    ##Handicap
    
    def handicap_allowance(user)
      golf_outing = self.tournament.golf_outing_for_player(user)
      course_handicap = golf_outing.course_handicap
    
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
      return nil
    end
    
    ##Payouts
    
    def assign_payouts_from_scores
      self.tournament.flights.each do |f|
        player_scores = []
      
        f.users.each do |player|
          score = self.player_score(player)
      
          player_scores << {player: player, score: score}
        end
      
        player_scores.sort! { |x,y| x[:score] <=> y[:score] }
      
        Rails.logger.debug { "Flights: #{self.tournament.flights.count} | Users: #{f.users.count} | PS: #{player_scores.count} | Payouts: #{f.payouts.count}" }
      
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

