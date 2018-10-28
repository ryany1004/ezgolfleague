class HandicapCalculationJob < ApplicationJob
  def perform(league)
    league.league_memberships.each do |membership|
      scorecards = self.scorecards_for_player(membership.user, league)

      calculated_handicap_index = self.handicap_for_player_with_scorecards(scorecards)

      Rails.logger.info { "Calculated Handicap Index of #{calculated_handicap_index} for user #{membership.user.complete_name} in #{league.name}" }

      user = membership.user
      user.handicap_index = calculated_handicap_index
      user.save

      self.update_future_tournaments(league, user)
    end
  end

  def scorecards_for_player(player, league)
    scorecards = []

    player.golf_outings.order(created_at: :desc).limit(100).each do |outing| #the 100 is arbitrary, to make sure we fetch enough records to have 10 valid scorecards
      if !outing.scorecard.has_empty_scores? && outing.in_league?(league)
        scorecards << outing.scorecard
      end
    end

    scorecards = scorecards.sort { |x,y| x.gross_score <=> y.gross_score }
    scorecards = scorecards[0, 10]

    scorecards
  end

  def handicap_for_player_with_scorecards(scorecards)
    handicap_sum = 0.0

    scorecards.each do |scorecard|
      gross_score = scorecard.gross_score
      course_tee_box = scorecard.golf_outing.course_tee_box

      if course_tee_box.rating <= 0 && course_tee_box.slope <= 0
        Rails.logger.debug "Course Tee Box Does Not Have Rating or Slope: #{course_tee_box.id}"

        next
      end

      differential = ((gross_score - course_tee_box.rating) * 113) / course_tee_box.slope

      Rails.logger.debug "Gross Score: #{gross_score}. Rating: #{course_tee_box.rating}. Slope: #{course_tee_box.slope}. Differential: #{differential}"

      handicap_sum += differential
    end

    Rails.logger.debug "Handicap Sum: #{handicap_sum}"

    if handicap_sum > 0
      averaged_handicap = ((handicap_sum / scorecards.count) * 0.96).round(1)
    else
      averaged_handicap = 0
    end

    averaged_handicap
  end

  def update_future_tournaments(league, user)
    tournaments = Tournament.tournaments_happening_at_some_point(nil, nil, [league], true).where(is_finalized: false)
    tournaments.each do |t|
      t.tournament_days.each do |td|
        scorecard = td.primary_scorecard_for_user(user)

        unless scorecard.blank?
          Rails.logger.info "Updating Scorecard #{scorecard.id} Course Handicap for #{user.complete_name}"

          scorecard.set_course_handicap(true)
        end
      end
    end
  end
end
