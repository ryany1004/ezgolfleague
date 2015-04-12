module Rankable
  extend ActiveSupport::Concern

  def ranked_player_list
    ranked_players = []
    
    self.players.each do |player|
      ranked_players << { id: player.id, name: player.complete_name, score: self.player_score(player) }
    end
    
    ranked_players.sort! { |x,y| y.score <=> x.score }
    
    return ranked_players
  end
  
end