module GameTypes
  class MatchPlay < GameTypes::GameTypeBase

    def display_name
      return "Match Play"
    end
    
    def game_type_id
      return 2
    end
    
    ##Setup
    
    def can_be_played?
      return false if self.tournament.tournament_groups.count == 0
      return false if self.tournament.flights.count == 0
    
      self.tournament.players.each do |p|
        return false if self.tournament.golfer_team_for_player(p) == nil
      end
    
      return true
    end
    
    ##Teams
    
    def allow_teams
      return GameTypes::TEAMS_REQUIRED
    end
    
    def number_of_players_per_team
      return 2
    end
    
    def players_create_teams?
      return false
    end
    
    ##Handicap
    
    def handicap_allowance(user) #TODO
      return nil
    end
    
    ##Scoring

    def player_points(user) #TODO
      return 0
    end
    
    private

  end
end