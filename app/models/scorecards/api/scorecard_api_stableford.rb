module Scorecards
  module Api
    class ScorecardAPIStableford < ScorecardAPIBase
      def additional_rows
        rows = []

        stableford_scorecard = tournament_day.scorecard_base_scoring_rule.stableford_scorecard_for_user(user: scorecard.golf_outing.user)
        rows << score_row_for_scorecard(stableford_scorecard, stableford_scorecard.name(true))

        rows
      end
    end
  end
end