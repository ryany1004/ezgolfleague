require 'active_record'

module GameTypes
  class Shamble < GameTypes::IndividualStrokePlay
    METADATA_KEY = "shamble_scorecard_for_best_ball"
    
    def display_name
      return "Shamble"
    end
    
    def game_type_id
      return 4
    end

    def show_other_scorecards?
      true
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
      tournament_day = scorecard.tournament_day
      team = tournament_day.golfer_team_for_player(scorecard.golf_outing.user)
    
      metadata = GameTypeMetadatum.find_or_create_by(golfer_team: team, search_key: METADATA_KEY)
      metadata.scorecard = scorecard
      metadata.save
    end
    
    def selected_scorecard_for_score(score)
      tournament_day = score.scorecard.tournament_day
      team = tournament_day.golfer_team_for_player(score.scorecard.golf_outing.user)
      metadata = GameTypeMetadatum.where(golfer_team: team, search_key: METADATA_KEY).first
      
      if metadata.blank?
        return nil
      else
        return metadata.scorecard
      end
    end
    
    ##UI
  
    def scorecard_score_cell_partial
      return "shared/game_types/shamble_popup"
    end
    
    def scorecard_post_embed_partial
      return "shared/game_types/shamble_post_embed"
    end
    
    def associated_text_for_score(score)      
      selected_card = self.selected_scorecard_for_score(score)
      return "Selected Best Ball" if selected_card == score.scorecard && score.course_hole.hole_number == 1 unless selected_card.blank?
      
      return nil
    end
    
  end
end