module GameTypes
  class MatchPlay < GameTypes::GameTypeBase

    def display_name
      return "Match Play"
    end
    
    def game_type_id
      return 2
    end
    
    def allow_teams
      return GameTypes::TEAMS_REQUIRED
    end
    
    def players_create_teams?
      return false
    end

  end
end