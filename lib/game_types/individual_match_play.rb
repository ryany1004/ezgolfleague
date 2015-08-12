module GameTypes
  class IndividualMatchPlay < GameTypes::GameTypeBase

    def display_name
      return "Individual Match Play"
    end
    
    def game_type_id
      return 2
    end
    
    ##Setup
    
    def can_be_played?
      return false if self.tournament_day.tournament_groups.count == 0
      return false if self.tournament_day.flights.count == 0
    
      self.tournament.players.each do |p|
        return false if self.tournament_day.golfer_team_for_player(p) == nil
      end
    
      return true
    end
    
    ##Teams
    
    def allow_teams
      return GameTypes::TEAMS_REQUIRED
    end
    
    def show_teams?
      return true
    end
    
    def number_of_players_per_team
      return 2
    end
    
    def players_create_teams?
      return false
    end
    
    def team_players_are_opponents?
      return true
    end
    
    def match_play_scorecard_for_user_in_team(user, golfer_team)
      scorecard = IndividualMatchPlayScorecard.new
      scorecard.user = user
      scorecard.golfer_team = golfer_team
      scorecard.calculate_scores

      return scorecard
    end
    
    ##Handicap
    
    def handicap_allowance(user)      
      opponent = self.opponent_for_user(user)
      unless opponent.blank?        
        golf_outing = self.tournament_day.golf_outing_for_player(user)
        
        user1_course_handicap = golf_outing.course_handicap
        user2_course_handicap = self.tournament_day.golf_outing_for_player(opponent).course_handicap
                
        baseline_handicap = 0
        if user1_course_handicap > user2_course_handicap
          baseline_handicap = user1_course_handicap - user2_course_handicap
          
          if golf_outing.course_tee_box.tee_box_gender == "Men"
            sorted_course_holes_by_handicap = self.tournament_day.course.course_holes.order("mens_handicap")
          else
            sorted_course_holes_by_handicap = self.tournament_day.course.course_holes.order("womens_handicap")
          end
          
          allowance = []
          while baseline_handicap > 0 do
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
                  
              if baseline_handicap > 0
                existing_hole[:strokes] = existing_hole[:strokes] + 1
                baseline_handicap = baseline_handicap - 1
              end
            end
          end
                    
          return allowance
        elsif user1_course_handicap < user2_course_handicap
          baseline_handicap = user2_course_handicap - user1_course_handicap
          
          return [] #user has no handicap allowance (scratch)
        else
          baseline_handicap = user1_course_handicap
          
          return []
        end
      end
      
      return []
    end
    
    ##Scoring
    
    def includes_extra_scoring_column?
      return true
    end
    
    def related_scorecards_for_user(user)      
      other_scorecards = []
      
      team = self.tournament_day.golfer_team_for_player(user)
      unless team.blank?
        user_match_play_card = self.match_play_scorecard_for_user_in_team(user, team)
        other_scorecards << user_match_play_card
        
        team.users.each do |u|
          if u != user
            other_scorecards << self.tournament_day.primary_scorecard_for_user(u) 
          
            other_user_match_play_card = self.match_play_scorecard_for_user_in_team(u, team)
            other_scorecards << other_user_match_play_card
          end
        end
      end
            
      return other_scorecards
    end
    
    def opponent_for_user(user)
      team = self.tournament_day.golfer_team_for_player(user)
      unless team.blank?
        team.users.each do |u|
          if u != user
            return u
          end
        end
      end
      
      return nil
    end

  end
end