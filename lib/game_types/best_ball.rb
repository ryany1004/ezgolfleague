require 'active_record'

module GameTypes
  class BestBall < GameTypes::IndividualStrokePlay
    attr_accessor :course_hole_number_suppression_list
    
    METADATA_KEY = "best_ball_scorecard_for_best_ball_hole"
    
    def initialize
      self.course_hole_number_suppression_list = []
    end
    
    def display_name
      return "Best Ball"
    end
    
    def game_type_id
      return 9
    end
    
    ##Teams
    
    def allow_teams
      return GameTypes::TEAMS_REQUIRED
    end
    
    def show_teams?
      return true
    end
    
    def number_of_players_per_team
      return GameTypes::VARIABLE
    end
    
    def players_create_teams?
      return false
    end
    
    ##Scoring
    
    def best_ball_scorecard_for_user_in_team(user, golfer_team, use_handicaps)
      scorecard = BestBallScorecard.new
      scorecard.course_hole_number_suppression_list = self.course_hole_number_suppression_list
      scorecard.user = user
      scorecard.golfer_team = golfer_team
      scorecard.should_use_handicap = use_handicaps
      scorecard.calculate_scores

      return scorecard
    end
    
    def related_scorecards_for_user(user)      
      other_scorecards = []
      
      team = self.tournament.golfer_team_for_player(user)
      unless team.blank?
        team.users.each do |u|
          if u != user
            other_scorecards << self.tournament.primary_scorecard_for_user(u) 
          end
        end
      end
      
      gross_best_ball_card = self.best_ball_scorecard_for_user_in_team(user, team, false)
      net_best_ball_card = self.best_ball_scorecard_for_user_in_team(user, team, true)
      
      other_scorecards << net_best_ball_card
      other_scorecards << gross_best_ball_card
            
      return other_scorecards
    end
    
  end
end