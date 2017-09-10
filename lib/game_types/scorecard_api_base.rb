module GameTypes
  class ScorecardAPIBase
    attr_accessor :tournament_day
    attr_accessor :scorecard
    attr_accessor :handicap_allowance

    def scorecard_representation
      rows = []

      #hole row
      rows << self.hole_row

      #par
      rows << self.par_row

      #scores
      rows << self.score_row

      #handicap
      rows << self.handicap_row(self.handicap_allowance)

      #additional rows
      rows = rows + self.additional_rows unless self.additional_rows.blank?

      #header info
      header_info = {golfer_name: self.scorecard.golf_outing.user.short_name, net_score: self.scorecard.net_score.to_s, gross_score: self.scorecard.gross_score.to_s, front_nine_score: self.scorecard.front_nine_score(true).to_s, back_nine_score: self.scorecard.back_nine_score(true).to_s}

      return {rows: rows, header: header_info}
    end

    def additional_rows
      return nil
    end

    def hole_row
      hole_info = []
      self.tournament_day.course_holes.each do |course_hole|
        hole_info << course_hole.hole_number.to_s
      end
      hole_info << "Out/In"
      hole_info << "HDCP"
      hole_info << "Gross"

      return {title: "Hole", contents: hole_info, should_bold: true, should_ornament: false}
    end

    def score_row
      return self.score_row_for_scorecard(self.scorecard, self.scorecard.name(true))
    end

    def score_row_for_scorecard(card, title)
      #Old Format
      score_info = []
      card.scores.each do |score|
        score_info << [score.strokes.to_s]
      end
      score_info << ["#{card.front_nine_score(false)}/#{card.front_nine_score(true)}", "#{card.back_nine_score(false)}/#{card.back_nine_score(true)}"]
      score_info << card.course_handicap.to_s
      score_info << "#{card.gross_score}/#{card.net_score}"

      #New format
      strokes = []
      card.scores.each do |score|
        strokes << score.strokes.to_s
      end

      front_back_nine_info = ["#{card.front_nine_score(false)}/#{card.front_nine_score(true)}", "#{card.back_nine_score(false)}/#{card.back_nine_score(true)}"]
      course_handicap = card.course_handicap.to_s
      gross_net_score = "#{card.gross_score}/#{card.net_score}"

      return {title: title, contents: score_info, strokes: strokes, front_back_nine_info: front_back_nine_info, course_handicap: course_handicap, gross_net_score: gross_net_score, should_bold: false, should_ornament: false}
    end

    def par_row
      par_info = []
      self.scorecard.scores.each do |score|
        par_info << score.course_hole.par.to_s
      end
      par_info << ""
      par_info << ""
      par_info << ""

      return {title: "Par", contents: par_info, should_bold: false, should_ornament: false}
    end

    def handicap_row(allowance)
      handicap_info = []
      self.tournament_day.course_holes.each do |course_hole|
        allowance.each do |h|
          if h[:course_hole] == course_hole
            if h[:strokes] != 0
              handicap_info << "-#{h[:strokes]}"
            else
              handicap_info << ""
            end
          end
        end
      end
      handicap_info << ""
      handicap_info << ""
      handicap_info << ""

      return {title: "", contents: handicap_info, should_bold: false, should_ornament: true}
    end

  end
end
