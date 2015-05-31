module GameTypes

  TEAMS_ALLOWED = "Allowed"
  TEAMS_REQUIRED = "Required"
  TEAMS_DISALLOWED = "Disallowed"

  class GameTypeBase
    attr_accessor :tournament
    
    def self.available_types
      return [GameTypes::IndividualStrokePlay.new, GameTypes::IndividualMatchPlay.new]
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
    
    def team_scorecard_for_team(golfer_team)
      return nil
    end
    
    ##Scoring

    def player_score(user)
      return nil
    end
    
    def player_points(user)
      return nil
    end
    
    ##Handicap
    
    def handicap_allowance(user)
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

