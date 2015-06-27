require 'active_record'

module GameTypes
  class Scramble < GameTypes::IndividualStrokePlay
    METADATA_KEY = "scramble_scorecard_for_best_ball_hole"
    
    def display_name
      return "Scramble"
    end
    
    def game_type_id
      return 6
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
    
    ##Metadata
    
    def update_metadata(metadata)
      scorecard = Scorecard.find(metadata[:scorecard_id])
      tournament = scorecard.tournament
      team = tournament.golfer_team_for_player(scorecard.golf_outing.user)
      course_hole = CourseHole.find(metadata[:course_hole_id])

      metadata = GameTypeMetadatum.find_or_create_by(golfer_team: team, course_hole: course_hole, search_key: METADATA_KEY)
      metadata.scorecard = scorecard
      metadata.save
    end
    
    def selected_scorecard_for_score(score) #this is the one selected as the tee shot
      return nil if score.scorecard.golf_outing.blank?
      
      tournament = score.scorecard.tournament
      team = tournament.golfer_team_for_player(score.scorecard.golf_outing.user)
      metadata = GameTypeMetadatum.where(golfer_team: team, course_hole: score.course_hole, search_key: METADATA_KEY).first

      if metadata.blank?
        return nil
      else
        return metadata.scorecard
      end
    end
    
    ##UI
  
    def scorecard_score_cell_partial
      return "shared/game_types/scramble_popup"
    end
    
    def scorecard_post_embed_partial
      return "shared/game_types/scramble_post_embed"
    end
    
    def associated_text_for_score(score)      
      selected_card = self.selected_scorecard_for_score(score)
      return "Tee Shot" if selected_card == score.scorecard unless selected_card.blank?

      return nil
    end
    
  end
end