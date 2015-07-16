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
    
    ##Setup
    
    def setup_partial
      return "shared/game_type_setup/scramble"
    end
    
    def handicap_percentage_key
      return "HandicapPercentageKey-T-#{self.tournament.id}-GT-#{self.game_type_id}"
    end
    
    def save_setup_details(game_type_options)
      handicap_percentage = 0
      handicap_percentage = game_type_options["handicap_percentage"]
      
      metadata = GameTypeMetadatum.find_or_create_by(search_key: handicap_percentage_key)
      metadata.float_value = handicap_percentage
      metadata.save
    end
    
    def remove_game_type_options
      metadata = GameTypeMetadatum.where(search_key: handicap_percentage_key).first
      metadata.destroy unless metadata.blank?
    end
    
    def current_handicap_percentage
      metadata = GameTypeMetadatum.where(search_key: handicap_percentage_key).first
      
      if metadata.blank?
        return "0.0"
      else
        return metadata.float_value
      end
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
    
    ##Scoring
    
    def related_scorecards_for_user(user)
      return []
    end
    
    def override_scorecard_name_for_scorecard(scorecard)
      player_names = scorecard.golf_outing.user.last_name + "/"
      
      other_members = self.tournament.other_group_members(scorecard.golf_outing.user)
      other_members.each do |player|
        player_names << player.last_name
        
        player_names << "/" if player != other_members.last
      end
  
      return "#{player_names} Scramble"
    end
    
    def after_updating_scores_for_scorecard(scorecard)   
      Scorecard.transaction do
        self.tournament.other_group_members(scorecard.golf_outing.user).each do |player|
          other_scorecard = self.tournament.primary_scorecard_for_user(player)
        
          Rails.logger.info { "Copying Score Data From #{scorecard.golf_outing.user.id} to #{player.id}" }
        
          scorecard.scores.each do |score|
            other_score = other_scorecard.scores.where(course_hole: score.course_hole).first
            other_score.strokes = score.strokes
            other_score.save
          end
        end
      end
    end
    
    def handicap_allowance(user)
      return nil #TODO: update w/ variable
    end
    
  end
end