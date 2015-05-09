module Playable
  extend ActiveSupport::Concern

  def players
    players = []
    
    self.tournament_groups.each do |group|
      group.players_signed_up.each do |player|
        players << player
      end
    end
    
    return players
  end

  def number_of_players
    number_of_players = 0
    
    self.tournament_groups.each do |group|
      number_of_players = number_of_players + group.players_signed_up.count
    end
    
    return number_of_players
  end

  def includes_player?(user)
    player_included = false
    
    self.tournament_groups.each do |group|
      group.players_signed_up.each do |player|
        player_included = true if player == user
      end
    end
    
    return player_included
  end
  
  def flight_for_player(user)        
    self.flights.each do |f|
      return f if f.users.include? user
    end
    
    return nil
  end
  
  def golf_outing_for_player(user)
    self.tournament_groups.each do |group|
      group.teams.each do |team|
        team.golf_outings.each do |outing|
          return outing if outing.user == user
        end
      end
    end
    
    return nil
  end
  
end