module GameTypes

  TEAMS_ALLOWED = "Allowed"
  TEAMS_REQUIRED = "Required"
  TEAMS_DISALLOWED = "Disallowed"

  class GameTypeBase
    attr_accessor :tournament
    
    def self.available_types
      return [GameTypes::IndividualStrokePlay.new, GameTypes::MatchPlay.new]
    end
    
    def display_name
      return nil
    end
    
    def game_type_id
      return nil
    end
    
    ##Teams
    
    def allow_teams
      return GameTypes::TEAMS_DISALLOWED
    end
    
    def players_create_teams?
      return true
    end
    
    def show_team_scores_for_all_teammates?
      return true
    end
    
    ##Scoring

    def player_score(user)
      return nil
    end
    
    def player_points(user)
      return nil
    end
    
    ##Ranking
    
    def flights_with_rankings
      return nil
    end
    
    ##Payouts
    
    def assign_payouts_from_scores
      return nil
    end
    
  end

end

