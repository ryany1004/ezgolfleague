module ScoringComputer
  class TeamMatchPlayBestBallScoringComputer < MatchPlayScoringComputer
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

        Rails.logger.info { "TeamMatchPlayBestBallScoringComputer comparing #{matchup.team_a.name} and #{matchup.team_b.name}" }

        match_play_scorecard = ScoringRuleScorecards::TeamMatchPlayBestBallScorecard.new
        match_play_scorecard.team_a_scorecard = team_a_best_ball_scorecard
        match_play_scorecard.team_b_scorecard = team_b_best_ball_scorecard
        match_play_scorecard.scoring_rule = @scoring_rule
        match_play_scorecard.calculate_scores

        if match_play_scorecard.scorecard_result == ::ScoringRuleScorecards::MatchPlayScorecardResult::WON
          winners << { team: matchup.team_a, details: match_play_scorecard.extra_scoring_column_data }

          matchup.winning_team = matchup.team_a
          matchup.save
        elsif match_play_scorecard.scorecard_result == ::ScoringRuleScorecards::MatchPlayScorecardResult::LOST
          winners << { team: matchup.team_b, details: 'W' } # overriding this to a 'W' because this is the other team

          matchup.winning_team = matchup.team_b
          matchup.save
        elsif match_play_scorecard.scorecard_result == ::ScoringRuleScorecards::MatchPlayScorecardResult::TIED
          ties << { team: matchup.team_a, details: match_play_scorecard.extra_scoring_column_data }
          ties << { team: matchup.team_b, details: match_play_scorecard.extra_scoring_column_data }
        else
          Rails.logger.info { "TeamMatchPlayBestBallScoringComputer did not produce a final result for matchup #{matchup.id}. #{match_play_scorecard.extra_scoring_column_data}" }
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
        details = u[:details]

        PayoutResult.create(league_season_team: winning_team, scoring_rule: @scoring_rule, points: primary_payout.points, detail: details)
      end

      ties.each do |u|
        winning_team = u[:team]
        details = u[:details]

        PayoutResult.create(league_season_team: winning_team, scoring_rule: @scoring_rule, points: primary_payout.points / 2, detail: details)
      end
    end
  end
end
