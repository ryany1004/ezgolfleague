class HandicapCalculationJob < ApplicationJob
  def perform(league)
    league.league_memberships.each do |membership|
      scorecards = self.scorecards_for_player(membership.user)

      calculated_handicap = self.handicap_for_player_with_scorecards(scorecards).round

      Rails.logger.info { "Calculated Handicap of #{calculated_handicap} for user #{membership.user.complete_name} in #{league.name}" }

      membership.course_handicap
      membership.save
    end
  end

  def scorecards_for_player(player)
    scorecards = []

    player.golf_outings.order("created_at DESC").limit(20).each do |outing|
      scorecards << outing.scorecard if !outing.scorecard.has_empty_scores?
    end

    scorecards = scorecards.sort { |x,y| x.gross_score <=> y.gross_score }
    scorecards = scorecards[0, 10]

    scorecards
  end

  def handicap_for_player_with_scorecards(scorecards)
    handicap_sum = 0.0

    scorecards.each do |scorecard|
      gross_score = scorecard.gross_score
      course = scorecard.golf_outing.tournament_group.tournament_day.course
      user = scorecard.golf_outing.user

      handicap_sum += user.index_derived_handicap(nil, scorecard.golf_outing)
    end

    averaged_handicap = handicap_sum / scorecards.count

    averaged_handicap
  end
end
