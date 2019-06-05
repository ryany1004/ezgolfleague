class StrokePlayScoringRule < ScoringRule
  include ::StrokePlayScoringRuleSetup
  include ::StrokePlayScorecardSupport

  def name
    'Individual Stroke Play'
  end

  def description
    'Traditional stroke play for individual players.'
  end

  def legacy_game_type_id
    1
  end

  def scoring_computer
    ScoringComputer::StrokePlayScoringComputer.new(self)
  end

  def show_other_scorecards?
    true
  end

  # TODO: this doesn't use the superclass version - should it?
  def users_eligible_for_payouts
    eligible_player_list = []

    if tournament.tournament_days.count == 1
      eligible_player_list = tournament.qualified_players
    else # only players that play all days can win
      tournament.qualified_players.each do |player|
        player_played_all_days = true

        tournament.tournament_days.each do |day|
          player_played_all_days = false if !tournament.includes_player?(player, day)
        end

        eligible_player_list << player if player_played_all_days
      end
    end

    eligible_player_list.uniq
  end
end
