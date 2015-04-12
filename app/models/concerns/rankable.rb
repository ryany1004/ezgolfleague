module Rankable
  extend ActiveSupport::Concern
  include Rails.application.routes.url_helpers

  def ranked_player_list
    ranked_players = []
    
    self.players.each do |player|
      score = self.player_score(player)
      
      scorecard = self.primary_scorecard_for_user(player)
      scorecard_url = play_scorecard_path(scorecard)
      
      ranked_players << { id: player.id, name: player.complete_name, score: score, scorecard_url: scorecard_url } if score > 0
    end
    
    ranked_players.sort! { |x,y| x[:score] <=> y[:score] }
    
    return ranked_players
  end
  
end