module GameTypes
  class TwoManComboScrambleBestBall < GameTypes::IndividualStrokePlay
    
    def display_name
      return "Two-Man Combo: Scramble / Best Ball"
    end
    
    def game_type_id
      return 12
    end
    
    ##Teams

    def number_of_players_per_team
      return 2
    end
    
    def allow_teams
      return GameTypes::TEAMS_REQUIRED
    end
    
    def show_teams?
      return true
    end
    
    def players_create_teams?
      return false
    end
    
    ##UI
    
    def update_metadata(metadata)
      course_hole = CourseHole.find(metadata[:course_hole_id])
      if course_hole.hole_number < 10
        game_type = Scramble.new
        game_type.tournament = self.tournament
        
        return game_type.update_metadata(metadata)
      end
    end
  
    def selected_scorecard_for_score(score)
      if score.course_hole.hole_number < 10
        game_type = Scramble.new
        game_type.tournament = self.tournament
        
        return game_type.selected_scorecard_for_score(score)
      end
    end
  
    def scorecard_score_cell_partial
      return "shared/game_types/scramble_best_ball_popup"
    end
    
    def scorecard_post_embed_partial
      return "shared/game_types/scramble_post_embed"
    end

    ##Scores
    
    def best_ball_scorecard_for_user_in_team(user, golfer_team, use_handicaps)
      game_type = BestBall.new
      game_type.tournament = self.tournament
      
      return game_type.best_ball_scorecard_for_user_in_team(user, golfer_team, use_handicaps)
    end
    
    def related_scorecards_for_user(user)      
      game_type = BestBall.new
      game_type.tournament = self.tournament
      game_type.course_hole_number_suppression_list = [1,2,3,4,5,6,7,8,9]
      
      return game_type.related_scorecards_for_user(user) 
    end

    def associated_text_for_score(score)      
      selected_card = self.selected_scorecard_for_score(score)
      return "Tee Shot" if selected_card == score.scorecard unless selected_card.blank?

      return nil
    end

  end
end