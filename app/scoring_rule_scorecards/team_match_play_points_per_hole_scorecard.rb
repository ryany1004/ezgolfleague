module ScoringRuleScorecards
  class TeamMatchPlayPointsPerHoleScorecard < ScoringRuleScorecards::MatchPlayScorecard
    def points_per_hole_award(per_win = 2, per_tie = 1)
      points_earned = 0

      user1 = user
      user2 = opponent

      return (@scoring_rule.course_holes.count * per_win) if @scoring_rule.user_disqualified?(opponent)

      scorecard1 = tournament_day.primary_scorecard_for_user(user1)
      scorecard2 = tournament_day.primary_scorecard_for_user(user2)

      user1_handicap_allowance = @scoring_rule.handicap_computer.match_play_handicap_allowance(user: user1)
      user2_handicap_allowance = @scoring_rule.handicap_computer.match_play_handicap_allowance(user: user2)

      @scoring_rule.course_holes.each do |hole|
        user1_score = scorecard1.scores.find_by(course_hole: hole)
        user2_score = scorecard2.scores.find_by(course_hole: hole)

        user1_hole_score = adjusted_strokes(user1_score.strokes, user1_handicap_allowance, hole)
        user2_hole_score = adjusted_strokes(user2_score.strokes, user2_handicap_allowance, hole)

        if user1_hole_score < user2_hole_score # user 1 won this hole
          points_earned += per_win
        elsif user1_hole_score > user2_hole_score # user 1 lost this hole
          # do nothing
        else
          points_earned += per_tie
        end
      end

      points_earned
    end
  end
end
