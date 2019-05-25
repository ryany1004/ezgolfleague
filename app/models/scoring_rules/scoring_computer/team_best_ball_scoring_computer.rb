module ScoringComputer
  class TeamBestBallScoringComputer < StrokePlayScoringComputer
    attr_accessor :winners
    attr_accessor :ties

    def initialize(scoring_rule)
      super(scoring_rule)

      self.winners = []
      self.ties = []
    end

    def generate_tournament_day_results
      super

      tournament_day.league_season_team_tournament_day_matchups.each do |matchup|
        next if matchup.team_a.blank? || matchup.team_b.blank?

        team_a_best_ball_scorecard = @scoring_rule.best_ball_scorecard_for_team(matchup.team_a)
        team_b_best_ball_scorecard = @scoring_rule.best_ball_scorecard_for_team(matchup.team_b)

        Rails.logger.info { "TeamBestBallScoringComputer comparing #{matchup.team_a.name} and #{matchup.team_b.name}" }

        if team_a_best_ball_scorecard.net_score < team_b_best_ball_scorecard.net_score
          winners << { team: matchup.team_a, net_score: team_a_best_ball_scorecard.net_score }

          matchup.winning_team = matchup.team_a
          matchup.save
        elsif team_a_best_ball_scorecard.net_score > team_b_best_ball_scorecard.net_score
          winners << { team: matchup.team_b, net_score: team_b_best_ball_scorecard.net_score }

          matchup.winning_team = matchup.team_b
          matchup.save
        else
          ties << { team: matchup.team_a, net_score: team_a_best_ball_scorecard.net_score }
          ties << { team: matchup.team_b, net_score: team_b_best_ball_scorecard.net_score }
        end
      end
    end

    def assign_payouts
      Rails.logger.info { "assign_payouts #{self.class}" }

      @scoring_rule.payout_results.destroy_all

      payout_count = @scoring_rule.payouts.count
      Rails.logger.info { "Payouts: #{payout_count}" }
      return if payout_count.zero?

      # assign payouts
      primary_payout = @scoring_rule.payouts.first
      raise "#{self.class} trying to be used with non splittable payouts." unless primary_payout.apply_as_duplicates?

      winners.each do |u|
        winning_team = u[:team]
        net_score = u[:net_score]

        PayoutResult.create(league_season_team: winning_team,
                            scoring_rule: @scoring_rule,
                            points: primary_payout.points,
                            details: "Win #{net_score}")
      end

      ties.each do |u|
        winning_team = u[:team]
        net_score = u[:net_score]

        PayoutResult.create(league_season_team: winning_team,
                            scoring_rule: @scoring_rule,
                            points: primary_payout.points / 2,
                            details: "Tie #{net_score}")
      end
    end
  end
end
