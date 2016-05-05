module GameTypes
  class ScorecardAPIBestBall < GameTypes::ScorecardAPIBase

    def additional_rows
      rows = []

      other_scorecards = self.tournament_day.game_type.related_scorecards_for_user(self.scorecard.golf_outing.user, false)

      other_scorecards.each do |card|
        rows << self.score_row_for_scorecard(card, card.name(true))

        unless card.golf_outing.blank?
          user_handicap_info = self.tournament_day.handicap_allowance(card.golf_outing.user)

          rows << self.handicap_row(user_handicap_info)
        end
      end

      return rows
    end

  end
end
