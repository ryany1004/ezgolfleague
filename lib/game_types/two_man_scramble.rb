module GameTypes
  class TwoManScramble < GameTypes::Scramble
    
    def display_name
      return "Two-Man Scramble"
    end
    
    def game_type_id
      return 7
    end
    
    ##Teams

    def number_of_players_per_team
      return 2
    end

  end
end