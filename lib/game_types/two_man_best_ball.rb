module GameTypes
  class TwoManBestBall < GameTypes::BestBall
    
    def display_name
      return "Two-Man Best Ball"
    end
    
    def game_type_id
      return 10
    end
    
    ##Teams

    def number_of_players_per_team
      return 2
    end

  end
end