module Rankable
  extend ActiveSupport::Concern

  def ranked_player_list
    ranked_players = []
    
    self.players.each do |player|
      score = self.player_score(player)
      
      ranked_players << { id: player.id, name: player.complete_name, score: score } if score > 0
    end
    
    ranked_players.sort! { |x,y| x[:score] <=> y[:score] }
    
    return ranked_players
  end
  
end