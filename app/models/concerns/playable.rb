module Playable
  extend ActiveSupport::Concern

  def players
    players = []
  
    self.tournament_days.each do |day|
      day.tournament_groups.each do |group|
        group.players_signed_up.each do |player|
          players << player unless players.include? player
        end
      end
    end

    return players
  end

  def number_of_players
    number_of_players = 0
  
    self.first_day.tournament_groups.each do |group|
      number_of_players = number_of_players + group.players_signed_up.count
    end
  
    return number_of_players
  end

  def includes_player?(user)
    player_included = false
  
    self.tournament_days.each do |day|
      day.tournament_groups.each do |group|
        group.players_signed_up.each do |player|
          player_included = true if player == user
        end
      end
    end
  
    return player_included
  end
  
  def total_score(user)
    total_score = 0
    
    self.tournament_days.each do |day|
      total_score += day.player_score(user)
    end
    
    return total_score
  end
  
  def total_points(user)
    total_points = 0
    
    self.tournament_days.each do |day|
      total_points += day.player_points(user)
    end
    
    return total_points
  end
  
end