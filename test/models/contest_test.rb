require 'test_helper'

class ContestTest < ActiveSupport::TestCase

  def setup
    @user = User.where(email: "hunter@lastonepicked.com").first
    @tournament = Tournament.where(name: "Brunswick June 2016").first
    @tournament_day = @tournament.tournament_days.first
    @tournament_group = @tournament_day.tournament_groups.first

    @tournament_day.add_player_to_group(@tournament_group, @user)
    generate_scores_for_user_tournament_day(@user, @tournament_day)
  end
  
  test "net + gross skins scores correctly" do
    contest = Contest.where(name: "Net + Gross Skins").first
    contest.add_user(@user)

    contest.score_contest

    contest.reload
    results = contest.contest_results
    results_users = results.map(&:winner)

    if results_users.include?(@user)
      assert true
    else
      results_users.each do |user|
        Rails.logger.info { "User: #{user.complete_name}" }
      end
      
      assert false, "User not included in winners. Users: #{results_users.count}. Results: #{contest.contest_results.count}"
    end
  end
  
  test "manual contest override" do
    contest = Contest.where(name: "Manual Net Low w/ Override").first
    contest.add_user(@user)

    contest.score_contest
    
    contest.reload
    result = contest.contest_results.first
        
    if result.payout_amount == contest.overall_winner_payout_amount && result.points == contest.overall_winner_points
      assert true
    else
      assert false, "Payout amount did not match manual data entry"
    end
  end
  
end
