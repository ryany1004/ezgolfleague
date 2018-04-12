module GameTypes
  class TwoManShamble < GameTypes::Shamble
    
    def display_name
      return "Two-Man Shamble"
    end
    
    def game_type_id
      return 5
    end

    def show_other_scorecards?
      true
    end
    
    ##Teams
    
    def allow_teams
      return GameTypes::TEAMS_REQUIRED
    end
    
    def number_of_players_per_team
      return 2
    end

  end
end