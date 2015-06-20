module GameTypes
  class FourManScramble < GameTypes::Scramble
    
    def display_name
      return "Four-Man Scramble"
    end
    
    def game_type_id
      return 8
    end
    
    ##Teams

    def number_of_players_per_team
      return 4
    end

  end
end