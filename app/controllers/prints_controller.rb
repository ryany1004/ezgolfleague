class PrintsController < BaseController
  before_action :fetch_tournament_details

  def print_scorecards
    @print_cards = []

    players_for_day = @tournament.players_for_day(@tournament_day)
    players_for_day.each do |player|
      primary_scorecard = @tournament_day.primary_scorecard_for_user(player)

      other_scorecards = []
      @tournament_day.displayable_scoring_rules.each do |rule|
        rule.related_scorecards_for_user(player, true).each do |other_card|
          if other_card.user != player && !other_scorecards.map(&:user).include?(other_card&.user)
            other_scorecards << other_card
          end
        end
      end

      if other_scorecards.count < 4
        number_to_create = (4 - other_scorecards.count) - 1

        number_to_create.times do
          extra_scorecard = ScoringRuleScorecards::EmptyLineScorecard.new
          extra_scorecard.scores_for_course_holes(@tournament_day.scorecard_base_scoring_rule.course_holes)

          other_scorecards << extra_scorecard
        end
      end

      scorecard_presenter = ScorecardPresenter.new({ primary_scorecard: primary_scorecard, secondary_scorecards: other_scorecards, current_user: @current_user })

      @print_cards << { p: scorecard_presenter } if !printable_cards_includes_player?(@print_cards, player)
    end

    render layout: false
  end

  def fetch_tournament_details
    @tournament = Tournament.find(params[:tournament_id])

    if params[:tournament_day].blank?
      @tournament_day = @tournament.tournament_days.includes(tournament_groups: [golf_outings: [:user, scorecard: :scores]]).first
    else
      @tournament_day = @tournament.tournament_days.where(id: params[:tournament_day]).includes(tournament_groups: [golf_outings: [:user, scorecard: :scores]]).first
    end
  end

  def printable_cards_includes_player?(printable_cards, player)
    printable_cards.each do |card|
      return true if card[:p].primary_scorecard.golf_outing.user == player

      card[:p].secondary_scorecards.each do |other|
        unless other.golf_outing.blank?
          return true if other.golf_outing.user == player
        end
      end
    end

    false
  end
end
