class StrokePlayScoringRule < ScoringRule
	include ::StrokePlayScoringRuleSetup
	include ::StrokePlayScorecardSupport

	def name
		"Individual Stroke Play"
	end

	def description
		"Traditional stroke play for individual players."
	end

	def scoring_computer
		ScoringComputer::StrokePlayScoringComputer.new(self)
	end

	def show_other_scorecards?
		true
	end

  def users_eligible_for_payouts
    eligible_player_list = []

    if self.tournament.tournament_days.count == 1
      eligible_player_list = self.tournament.qualified_players.map(&:id)
    else #only players that play all days can win
      self.tournament.qualified_players.each do |player|
        player_played_all_days = true

        self.tournament.tournament_days.each do |day|
          player_played_all_days = false if !self.tournament.includes_player?(player, day)
        end

        eligible_player_list << player.id if player_played_all_days
      end
    end

    eligible_player_list
  end

	def scorecard_api(scorecard:)
    handicap_allowance = self.handicap_allowance(scorecard.golf_outing.user)

		Scorecards::Api::ScorecardAPIBase.new(scorecard.tournament_day, scorecard, handicap_allowance)
	end
end