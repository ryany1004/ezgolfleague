module ScoringRuleScoring
  def user_score(user:, use_handicap: true, holes: [])
    tournament_day_result = self.tournament_day.tournament_day_results.where(aggregated_result: false).where(user: user).first

    if tournament_day_result.blank?
      tournament_day_result = self.score_user(user: user) 

      RankFlightsJob.perform_later(self.tournament_day)
    end

    return 0 if tournament_day_result.blank?

    if holes == [10, 11, 12, 13, 14, 15, 16, 17, 18]
      if use_handicap == true
        score = tournament_day_result.back_nine_net_score
      else
        score = self.compute_user_score(user: user, use_handicap: false, holes: holes)
      end
    elsif holes == [1, 2, 3, 4, 5, 6, 7, 8, 9]
      if use_handicap == true
        score = tournament_day_result.front_nine_net_score
      else
        score = tournament_day_result.front_nine_gross_score
      end
    else
      if use_handicap == true
        score = tournament_day_result.net_score
      else
        score = tournament_day_result.gross_score
      end
    end

    score
  end

  def compute_user_score(user:, use_handicap: true, holes: [])
  end

  def compute_adjusted_user_score(user:)
    return nil if !self.users.include? user

    Rails.logger.info { "compute_adjusted_user_score: #{user.complete_name}" }

    scorecard = self.tournament_day.primary_scorecard_for_user(user)
    if scorecard.blank?
      Rails.logger.info { "Returning 0 - No Scorecard" }

      return 0
    end

    total_score = 0

    scorecard.scores.each do |score|
      adjusted_score = scorecard.score_or_maximum_for_hole(strokes: score.strokes, course_handicap: scorecard.golf_outing.course_handicap, hole: score.course_hole)

      total_score = total_score + adjusted_score
    end

    Rails.logger.info { "User Adjusted Score: #{user.complete_name} - #{total_score}" }

    total_score = 0 if total_score < 0

    total_score
  end
end