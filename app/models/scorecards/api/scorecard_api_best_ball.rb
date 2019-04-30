module Scorecards
  module Api
    class ScorecardAPIBestBall < ScorecardAPIBase
      def additional_rows
        rows = []

        other_scorecards = tournament_day.scorecard_base_scoring_rule.related_scorecards_for_user(scorecard.golf_outing.user, false)

        other_scorecards.each do |card|
          rows << score_row_for_scorecard(card, card.name(true))

          next if card.golf_outing.blank?

          user_handicap_info = handicap_allowance(user: card.golf_outing.user)
          rows << handicap_row(user_handicap_info)
        end

        rows
      end
    end
  end
end
