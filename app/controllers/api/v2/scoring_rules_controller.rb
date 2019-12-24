class Api::V2::ScoringRulesController < BaseController
  respond_to :json

  before_action :fetch, except: :index

  def index
    @scoring_rules = ScoringRuleOption.scoring_rule_options(show_team_rules: false)

    render json: @scoring_rules.to_json
  end

  def create
    payload = ActiveSupport::JSON.decode(request.body.read)

    @errors = []

    scoring_rule = payload['className'].constantize.new(tournament_day: @tournament_day,
                                                        custom_name: payload['customName'],
                                                        dues_amount: payload['duesAmount'],
                                                        is_opt_in: payload['isOptIn'])
    @errors << scoring_rule.errors

    post_process_rule(scoring_rule, payload)

    if scoring_rule.save
      render json: scoring_rule
    else
      render json: { errors: @errors }
    end
  end

  def update
    payload = ActiveSupport::JSON.decode(request.body.read)

    @errors = []

    scoring_rule.update(custom_name: payload['customName'],
                        dues_amount: payload['duesAmount'],
                        is_opt_in: payload['isOptIn'])
    @errors << scoring_rule.errors

    post_process_rule(scoring_rule, payload, scoring_rule.users.empty?)

    scoring_rule.tournament_day_results.destroy_all # removed cached results as gametype influences scores

    render json: { errors: @errors }
  end

  def destroy
    scoring_rule.destroy

    update_primary_scoring_rule(@tournament_day)

    render json: :ok
  end

  private

  def scoring_rule
    @tournament_day.scoring_rules.find(params[:id])
  end

  def fetch
    @tournament = fetch_tournament_from_user_for_tournament_id(params[:tournament_id])
    @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
  end

  def post_process_rule(scoring_rule, payload, assign_players = true)
    assign_course_holes(scoring_rule, payload['holeConfiguration']['value'])

    assign_custom_configuration(scoring_rule, payload['customConfiguration'])

    update_payouts(scoring_rule, payload)

    assign_players(scoring_rule) if !scoring_rule.is_opt_in && assign_players

    configure_for_daily_teams if scoring_rule.team_type == ScoringRuleTeamType::DAILY && @tournament_day.daily_teams.count.zero?

    update_primary_scoring_rule(@tournament_day)

    manage_shadow_stroke_play(@tournament_day)
  end

  def assign_custom_configuration(scoring_rule, custom_config)
    scoring_rule.save_setup_details(custom_config)
  end

  def assign_course_holes(scoring_rule, hole_information)
    if hole_information == 'allHoles'
      holes = scoring_rule.tournament_day.course.course_holes
    elsif hole_information == 'frontNine'
      holes = scoring_rule.tournament_day.course.course_holes.where('hole_number < 10')
    elsif hole_information == 'backNine'
      holes = scoring_rule.tournament_day.course.course_holes.where('hole_number > 9')
    elsif hole_information == 'custom'
      raise
    end

    scoring_rule.course_holes = []

    holes.each do |ch|
      scoring_rule.course_holes << ch
    end
  end

  def update_tournament_date(tournament)
    return if tournament.tournament_days.first.blank?

    tournament.update(tournament_starts_at: tournament.tournament_days.first.tournament_at)
  end

  def update_primary_scoring_rule(tournament_day)
    tournament_day.reload

    if tournament_day.scorecard_base_scoring_rule.blank? && tournament_day.displayable_scoring_rules.first.present?
      tournament_day.scoring_rules.first.update(primary_rule: true)
    end
  end

  def assign_players(scoring_rule)
    @tournament_day.tournament.players_for_day(@tournament_day).each do |u|
      scoring_rule.users << u unless scoring_rule.users.include? u
    end
  end

  def configure_for_daily_teams
    @tournament_day.tournament_groups.each do |group|
      group.create_daily_teams
    end
  end

  def manage_shadow_stroke_play(tournament_day)
    TournamentService::ShadowStrokePlay.call(tournament_day)
  end

  def update_payouts(scoring_rule, payload)
    payouts_payload = payload['payouts']

    valid_ids = payouts_payload.map { |x| x['id'] }.compact
    scoring_rule.payouts.where('id NOT IN (?)', valid_ids).destroy_all if valid_ids.present?

    payouts_payload.each do |p|
      p['points'].blank? ? points = 0 : points = p['points']
      p['amount'].blank? ? amount = 0 : amount = p['amount']

      if p['id'].present?
        payout = scoring_rule.payouts.find(p['id'])
        payout.update(points: points, amount: amount)
      else
        Payout.create(scoring_rule: scoring_rule, points: points, amount: amount, flight_id: p['flightId'])
      end
    end
  end
end
