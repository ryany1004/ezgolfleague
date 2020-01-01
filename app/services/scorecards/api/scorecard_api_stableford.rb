module Scorecards
  module Api
    class ScorecardApiStableford < ScorecardApiBase
      def additional_rows
        rows = []

        stableford_scorecard = tournament_day.scorecard_base_scoring_rule.stableford_scorecard_for_user(user: scorecard.golf_outing.user)
        rows << score_row_for_scorecard(stableford_scorecard, stableford_scorecard.name(true), true)

        rows
      end
    end
  end
end
