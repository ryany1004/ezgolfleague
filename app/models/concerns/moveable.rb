module Moveable
  extend ActiveSupport::Concern

  def move_player_to_tournament_group(user, new_tournament_group)
    golf_outing = self.golf_outing_for_player(user)

    golf_outing.tournament_group = new_tournament_group
    golf_outing.save
  end
end
