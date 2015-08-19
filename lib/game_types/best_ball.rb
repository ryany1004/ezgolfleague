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
    
    def compute_player_score(user, use_handicap = true, holes = [])
      return nil if !self.tournament.includes_player?(user)

      total_score = 0

      team = self.tournament_day.golfer_team_for_player(user)
      scorecard = self.best_ball_scorecard_for_user_in_team(user, team, use_handicap)
      return 0 if scorecard.blank? || scorecard.scores.blank?

      scorecard.scores.each do |score|
        should_include_score = true #allows us to calculate partial scores, i.e. back 9
        if holes.blank? == false
          should_include_score = false if !holes.include? score.course_hole.hole_number
        end

        if should_include_score == true
          hole_score = score.strokes

          total_score = total_score + hole_score
        end
      end

      total_score = 0 if total_score < 0

      return total_score
    end
    
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
      
      team = self.tournament_day.golfer_team_for_player(user)
      unless team.blank?
        team.users.each do |u|
          if u != user
            other_scorecards << self.tournament_day.primary_scorecard_for_user(u) 
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