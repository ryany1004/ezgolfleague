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
    
  end
end