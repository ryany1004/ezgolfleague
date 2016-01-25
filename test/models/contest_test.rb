require 'test_helper'

class ContestTest < ActiveSupport::TestCase

  test "net + gross skins" do
    user = User.where(email: "hunter@lastonepicked.com").first
    tournament = Tournament.where(name: "Brunswick June 2016").first
    tournament_day = tournament.first
    tournament_group = tournament_day.tournament_groups.first

    tournament_day.add_player_to_group(tournament_group, user)
    generate_scores_for_user_tournament_day(user, tournament_day)
    
    
  end
  
end
