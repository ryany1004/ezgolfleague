class CalculateNetScoresJob < ApplicationJob
  queue_as :calculations

  def perform(scorecard)
    stroke_play = StrokePlayScoringRule.new(tournament_day: scorecard.tournament_day)

    handicap_computer = stroke_play.handicap_computer
    handicap_allowance = handicap_computer.handicap_allowance(user: scorecard.user)

    scorecard.scores.includes(:course_hole).each do |score|
      score.net_strokes = score.strokes

      if handicap_allowance.present?
        handicap_allowance.each do |h|
          next unless h[:course_hole] == score.course_hole

          hole_net_score = score.strokes

          if h[:strokes] != 0
            hole_adjusted_score = score.strokes - h[:strokes]
            hole_net_score = [hole_adjusted_score, 0].max
          end

          score.net_strokes = hole_net_score
        end
      end

      score.save
    end
  end
end
