module GameTypes
  class TwoManIndividualStrokePlayScorecard < GameTypes::DerivedScorecard
    attr_accessor :should_use_handicap
    attr_accessor :handicap_indices

    def initialize
      super

      self.handicap_indices = Hash.new
    end

    def name(shorten_for_print = false)
      if self.should_use_handicap == true
        if shorten_for_print == true
          return "Net"
        else
          return "Team Net"
        end
      else
        if shorten_for_print == true
          return "Gross"
        else
          return "Team Gross"
        end
      end
    end

    def should_subtotal?
      return false
    end

    def should_total?
      return true
    end

    def handicap_allowance_for_user(user)
      if self.should_use_handicap == false
        return nil
      end

      if self.handicap_indices["#{user.id}"]
        return self.handicap_indices["#{user.id}"]
      else
        handicap_allowance = self.tournament_day.handicap_allowance(user)
        self.handicap_indices["#{user.id}"] = handicap_allowance

        return handicap_allowance
      end
    end

    def calculate_scores
      new_scores = []

      if golfer_team.blank?
        Rails.logger.debug { "Calculate Scores - No Team" }

        return
      end

      self.golfer_team.tournament_day.course_holes.each_with_index do |hole, i|
        score = DerivedScorecardScore.new
        score.scorecard = self
        score.course_hole = hole

        comparable_scores = []
        self.golfer_team.users.each do |user|
          scorecard = self.golfer_team.tournament_day.primary_scorecard_for_user(user)

          unless scorecard.blank? || scorecard.scores.blank?
            raw_score = scorecard.scores.where(course_hole: hole).first.strokes
          else
            Rails.logger.info { "Raw Score is 0 - No Scorecard or Scores: \(scorecard.id) \(scorecard.scores&.where(course_hole: hole))" }

            raw_score = 0
          end

          if self.should_use_handicap == true
            if raw_score == 0
              hole_score = 0
            else
              hole_score = self.adjusted_strokes(raw_score, self.handicap_allowance_for_user(user), hole)
            end
          else
            hole_score = raw_score
          end

          comparable_scores << hole_score
        end

        score.strokes = self.strokes_for_scores(comparable_scores, hole)
        new_scores << score
      end

      self.scores = new_scores
    end

    def strokes_for_scores(comparable_scores, hole)
      return 0 if comparable_scores.blank?

      total_strokes = 0
      comparable_scores.each do |score|
        total_strokes += score if score > 0
      end

      total_strokes
    end
  end
end
