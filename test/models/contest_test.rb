require 'test_helper'

class ContestTest < ActiveSupport::TestCase

  test "net + gross skins scores correctly" do
    user = User.where(email: "hunter@lastonepicked.com").first
    tournament = Tournament.where(name: "Brunswick June 2016").first
    tournament_day = tournament.tournament_days.first
    tournament_group = tournament_day.tournament_groups.first

    tournament_day.add_player_to_group(tournament_group, user)
    generate_scores_for_user_tournament_day(user, tournament_day)

    contest = Contest.where(name: "Net + Gross Skins").first
    contest.add_user(user)

    tournament.finalize

    results = contest.contest_results
    results_users = results.map(&:winner)

    if results_users.include?(user)
      assert true
    else
      assert false
    end
  end
  
end
