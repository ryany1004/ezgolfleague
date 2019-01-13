module Scorecards
  module Api
    class ScorecardAPIBestBall < ScorecardAPIBase
      def additional_rows
        rows = []

        other_scorecards = self.tournament_day.scorecard_base_scoring_rule.related_scorecards_for_user(self.scorecard.golf_outing.user, false)

        other_scorecards.each do |card|
          rows << self.score_row_for_scorecard(card, card.name(true))

          unless card.golf_outing.blank?
            user_handicap_info = self.handicap_allowance(card.golf_outing.user)

            rows << self.handicap_row(user_handicap_info)
          end
        end

        return rows
      end
    end
  end
end
