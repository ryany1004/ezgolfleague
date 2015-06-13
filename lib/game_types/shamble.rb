require 'active_record'

module GameTypes
  class Shamble < GameTypes::IndividualStrokePlay
    
    def display_name
      return "Shamble"
    end
    
    def game_type_id
      return 4
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
    
      metadata = GameTypeMetadatum.find_or_create_by(golfer_team: team, search_key: "shamble_scorecard_for_best_ball")
      metadata.scorecard = scorecard
      metadata.save
    end
    
    ##UI
  
    def scorecard_footer_partial
      return "shared/game_types/shamble_footer"
    end
    
    def associated_text_for_score(score)      
      tournament = score.scorecard.tournament
      team = tournament.golfer_team_for_player(score.scorecard.golf_outing.user)
      metadata = GameTypeMetadatum.where(golfer_team: team, search_key: "shamble_scorecard_for_best_ball").first
      
      unless metadata.blank?
        return "Selected" if metadata.scorecard == score.scorecard && score.course_hole.hole_number == 1
      end
      
      return nil
    end
    
  end
end