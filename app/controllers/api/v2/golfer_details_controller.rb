class Api::V2::GolferDetailsController < BaseController
  respond_to :json

  before_action :fetch

  def show
    @player = player
    @tournament_groups = @tournament_day.tournament_groups
    @player_scoring_rules = @tournament_day.optional_scoring_rules_for_user(user: @player)
  end

  def update
    payload = ActiveSupport::JSON.decode(request.body.read)

    @errors = []

    update_dues(player, @tournament, payload['duesPaid'])

    update_scoring_rules(player, @tournament_day, payload['scoringRules'])

    update_tournament_group(player, @tournament_day, payload['tournamentGroupId'])

    render json: { errors: @errors }
  end

  def destroy
    tournament_group = @tournament_day.tournament_group_for_player(player)
    @tournament_day.remove_player_from_group(tournament_group: tournament_group, user: player)

    render json: :ok
  end

  private

  def player
    User.find(params[:id])
  end

  def fetch
    @tournament = fetch_tournament_from_user_for_tournament_id(params[:tournament_id])
    @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
    @league = @tournament.league
  end

  def update_dues(player, tournament, dues_state)
    current_state = @tournament.user_has_paid?(@player)
    return if current_state == dues_state

    if dues_state # mark as paid
      dues_to_pay = tournament.dues_for_user(player)

      Payment.create(scoring_rule: @tournament_day.scorecard_base_scoring_rule, payment_amount: dues_to_pay, user: player, payment_type: 'Tournament Marked as Paid', payment_source: PAYMENT_METHOD_CREDIT_CARD)
    else # mark as unpaid
      scoring_rule_ids = tournament.tournament_days.map(&:scoring_rules).flatten.map(&:id)
      payments = Payment.where(scoring_rule: scoring_rule_ids).where(user: player)
      payments.destroy
    end
  end

  def update_scoring_rules(player, tournament_day, scoring_rule_ids)
    existing_scoring_rules_ids = tournament_day.optional_scoring_rules_for_user(user: player).map(&:id)
    return if existing_scoring_rules_ids.sort == scoring_rule_ids.sort

    scoring_rule_ids.each do |rid|
      unless existing_scoring_rules_ids.include?(rid)
        scoring_rule = ScoringRule.find(rid)

        scoring_rule.users << player
      end
    end

    existing_scoring_rules_ids.each do |rid|
      unless scoring_rule_ids.include?(rid)
        scoring_rule = ScoringRule.find(rid)

        scoring_rule.users.delete(player)
      end
    end
  end

  def update_tournament_group(player, tournament_day, tournament_group_id)
    existing_tournament_group_id = tournament_day.tournament_group_for_player(player).id
    return if existing_tournament_group_id == tournament_group_id

    new_tournament_group = TournamentGroup.find(tournament_group_id)
    tournament_day.move_player_to_tournament_group(player, new_tournament_group)
  end
end
