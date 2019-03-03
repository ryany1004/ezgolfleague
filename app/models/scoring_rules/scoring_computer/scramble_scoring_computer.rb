module ScoringComputer
	class ScrambleScoringComputer < StrokePlayScoringComputer
    def after_updating_scores_for_scorecard(scorecard:)
      Scorecard.transaction do
        @scoring_rule.other_group_members(user: scorecard.golf_outing.user).each do |player|
          other_scorecard = self.tournament_day.primary_scorecard_for_user(player)

          Rails.logger.debug { "Copying Score Data From #{scorecard.golf_outing.user.complete_name} to #{player.complete_name}" }

          scorecard.scores.each do |score|
            other_score = other_scorecard.scores.where(course_hole: score.course_hole).first
            other_score.strokes = score.strokes
            other_score.save
          end

          # make sure the results get updated also
          @scoring_rule.individual_tournament_day_results.where(user: player).destroy_all
        end
      end
    end

    def assign_payouts
      super

      Rails.logger.debug { "Assigning Team Scores" }

      @scoring_rule.reload

      @scoring_rule.payout_results.each do |result|
        team = self.tournament_day.daily_team_for_player(result.user)

        unless team.blank?
          team.users.where("id != ?", result.user.id).each do |teammate|
            Rails.logger.debug { "Scramble Teams: Assigning #{teammate.complete_name} to Payout #{result.id}" }

            PayoutResult.create(scoring_rule: @scoring_rule, payout: result.payout, user: teammate, flight: result.flight, amount: result.amount, points: result.points)
          end
        end
      end
    end
	end
end