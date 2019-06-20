module ScoringComputer
  class SkinsScoringComputer < BaseScoringComputer
    def generate_tournament_day_result(user:)
      # skins do not require TDR
    end

    def assign_payouts
      @scoring_rule.payout_results.destroy_all

      skins = users_with_skins(use_gross_scores: !@scoring_rule.use_net_score)
      per_skin = value_per_skin(skins: skins)

      skins.each do |s|
        scoring_rule_hole = @scoring_rule.scoring_rule_course_holes.find_by(course_hole: s[:hole])

        s[:winners].each do |winner|
          detail = s[:hole].hole_number.to_s

          PayoutResult.create(
            user: winner,
            scoring_rule: @scoring_rule,
            amount: per_skin,
            scoring_rule_course_hole: scoring_rule_hole,
            detail: detail,
            points: 0
          )
        end
      end

      combine_results(@scoring_rule.reload.payout_results)
    end

    def user_score_key(user:, hole:)
      "#{hole.id}-#{user.id}"
    end

    def combine_results(results, holes_are_unique: true)
      grouped_results = {}

      results.each do |r|
        user_results = grouped_results[r.user]

        if user_results.present?
          user_results << r
        else
          grouped_results[r.user] = [r]
        end
      end

      grouped_results.keys.each do |user|
        summed_amount = 0
        aggregate_details = []

        grouped_results[user].each do |r|
          summed_amount += r.amount
          aggregate_details << r.detail

          r.destroy
        end

        PayoutResult.create(
          user: user,
          scoring_rule: @scoring_rule,
          amount: summed_amount,
          detail: aggregate_details.join(', '),
          points: 0
        )
      end
    end

    def value_per_skin(skins:)
      winners_sum = 0

      skins.each do |s|
        winners = s[:winners]

        winners_sum += winners.count
      end

      return 0 if winners_sum.zero?

      total_pot = @scoring_rule.users_eligible_for_payouts.count * @scoring_rule.dues_amount

      Rails.logger.debug { "Value Per Skin: #{@scoring_rule.users_eligible_for_payouts.count} players with #{@scoring_rule.dues_amount} for pot of #{total_pot}. Winners sum: #{winners_sum}" }

      if total_pot.positive?
        (total_pot / winners_sum).floor
      else
        0
      end
    end

    def user_scores(use_gross_scores:)
      scores = {}

      @scoring_rule.users_eligible_for_payouts.each do |user|
        user_scorecard = tournament_day.primary_scorecard_for_user(user)
        next if user_scorecard.blank?

        @scoring_rule.course_holes.each do |hole|
          if use_gross_scores
            strokes = user_scorecard.scores.find_by(course_hole: hole).strokes
          else
            strokes = user_scorecard.scores.find_by(course_hole: hole).net_strokes
          end

          scores[user_score_key(user: user, hole: hole)] = strokes
        end
      end

      scores
    end

    def users_with_skins(use_gross_scores:)
      winners = []

      hole_scores = user_scores(use_gross_scores: use_gross_scores)

      @scoring_rule.course_holes.each do |hole|
        users_with_skins = []
        user_scores = []

        @scoring_rule.users_eligible_for_payouts.each do |user|
          user_scorecard = tournament_day.primary_scorecard_for_user(user)
          next if user_scorecard.blank?

          strokes = hole_scores[user_score_key(user: user, hole: hole)]
          next if strokes.blank? || (strokes.zero? && use_gross_scores) # strokes can be zero but only if net as handicap might take it down to zero or below

          Rails.logger.debug { "Adding User #{user.complete_name} with score #{strokes} to user_scores for hole #{hole.hole_number}" }

          user_scores << { user: user, score: strokes }
        end

        user_scores.sort! { |x, y| x[:score] <=> y[:score] }

        user = user_scores[0][:user]
        score = user_scores[0][:score]
        other_users = user_scores.map { |x| x[:user] }

        if user_scores.count == 1
          users_with_skins << user

          Rails.logger.info { "#{@scoring_rule.class}: User #{user_scores[0][:user].complete_name} got a regular skin for hole #{hole.hole_number}" }
        else
          if user_scores[0][:score] == user_scores[1][:score] # if there is a tie, they do not count
            Rails.logger.info { "#{@scoring_rule.class}: There was a tie - no skin awarded. #{user_scores[0][:user].complete_name} and #{user_scores[1][:user].complete_name} for hole #{hole.hole_number}" }
          else
            users_with_skins << user

            Rails.logger.info { "#{@scoring_rule.class}: User #{user.complete_name} got a regular skin for hole #{hole.hole_number}" }
          end
        end

        winners << { hole: hole, winners: users_with_skins } if users_with_skins.present?
      end

      winners
    end
  end
end
