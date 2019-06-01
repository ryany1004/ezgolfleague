module ScoringComputer
  class TotalSkinsScoringComputer < SkinsScoringComputer
    def apply_across_daily_teams?
      @scoring_rule.tournament_day.scorecard_base_scoring_rule.team_type == ScoringRuleTeamType::DAILY
    end

    def assign_payouts
      @scoring_rule.payout_results.destroy_all

      gross_birdie_winners = users_with_gross_birdie_skins
      net_skins_winners = users_with_skins(use_gross_scores: false)
      merged_winners = merge_winners(gross_winners: gross_birdie_winners, net_winners: net_skins_winners)

      per_skin = value_per_skin(skins: merged_winners)

      Rails.logger.debug { "Rule #{@scoring_rule.id} value per skin: #{per_skin}" }

      merged_winners.each do |s|
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

      combine_results(@scoring_rule.reload.payout_results, holes_are_unique: false)

      assign_payouts_across_daily_teams if apply_across_daily_teams?
    end

    def assign_payouts_across_daily_teams
      Rails.logger.info { 'Splitting Payouts for Daily Team Primary Scoring Rule' }

      @scoring_rule.tournament_day.daily_teams.each do |daily_team|
        next if daily_team.users.count.zero?

        team_results = @scoring_rule.payout_results.where(user: daily_team.users)

        team_results.each do |result|
          split_amount = result.amount / daily_team.users.count

          Rails.logger.debug { "Splitting payout #{result.amount} to #{split_amount} across #{daily_team.users.count}." }

          other_users = daily_team.users.where.not(id: result.user.id)
          other_users.each do |o|
            PayoutResult.create(
              user: o,
              scoring_rule: @scoring_rule,
              amount: split_amount,
              scoring_rule_course_hole: result.scoring_rule_course_hole,
              detail: result.detail,
              points: 0
            )
          end

          result.update(amount: split_amount)
        end
      end
    end

    def merge_winners(gross_winners:, net_winners:)
      all_winners = []

      gross_winners.each do |w|
        all_winners << w
      end

      net_winners.each do |w|
        all_winners.each do |all_winner|
          w[:winners].each do |w2|
            all_winner[:winners] << w2 if w[:hole] == all_winner[:hole]
          end
        end
      end

      all_winners
    end

    def users_with_gross_birdie_skins
      winners = []
      hole_scores = user_scores(use_gross_scores: true)

      @scoring_rule.course_holes.each do |hole|
        users_with_gross_birdie_skins = []

        gross_birdie_score = (hole.par - 1)

        @scoring_rule.users_eligible_for_payouts.each do |user|
          user_scorecard = tournament_day.primary_scorecard_for_user(user)
          next if user_scorecard.blank?

          strokes = hole_scores[user_score_key(user: user, hole: hole)]
          next if strokes.blank? || strokes.zero?

          if strokes <= gross_birdie_score # gross birdies or better count
            if @scoring_rule.team_type == ScoringRuleTeamType::DAILY # teams can only have ONE GROSS BIRDIE SKIN PER HOLE
              teammates_have_birdie_skin_for_hole = false

              daily_team = tournament_day.daily_team_for_player(user)
              if daily_team.present?
                daily_team.users.each do |teammate|
                  teammates_have_birdie_skin_for_hole = true if gross_birdie_skins.include? teammate
                end
              end

              if !teammates_have_birdie_skin_for_hole
                Rails.logger.debug { "Skins: Team #{daily_team.id} for User #{user.id} DOES NOT Have Pre-Existing Birdies - Ok to Add" }

                users_with_gross_birdie_skins << user

                Rails.logger.info { "Skins: User #{user.complete_name} scored a gross birdie skin for hole #{hole.hole_number} w/ score #{strokes}. Required score: #{gross_birdie_score}" }
              end
            else # not a team contest
              users_with_gross_birdie_skins << user

              Rails.logger.info { "Skins: User #{user.complete_name} scored a gross birdie skin for hole #{hole.hole_number} w/ score #{strokes}. Required score: #{gross_birdie_score}" }
            end
          end
        end

        winners << { hole: hole, winners: users_with_gross_birdie_skins }
      end

      winners
    end
  end
end
