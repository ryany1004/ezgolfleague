module GameTypes
  class TwoManShamble < GameTypes::Shamble
    
    def display_name
      return "Two-Man Shamble"
    end
    
    def game_type_id
      return 5
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
    
  end
end