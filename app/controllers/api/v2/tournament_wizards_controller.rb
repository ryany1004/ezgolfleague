class Api::V2::TournamentWizardsController < BaseController
  def create
    payload = ActiveSupport::JSON.decode(request.body.read)

    @errors = []
    url = nil

    tournament = Tournament.new(league: league,
                                name: payload['name'],
                                max_players: payload['number_of_players'],
                                signup_opens_at: formatted_time(payload['opens_at']),
                                signup_closes_at: formatted_time(payload['closes_at']),
                                auto_schedule_for_multi_day: 0,
                                show_players_tee_times: payload['show_tee_times'],
                                allow_credit_card_payment: league.stripe_is_setup?)

    Tournament.transaction do
      if tournament.save
        days = create_tournament_days(tournament, payload)
        days.each do |day|
          next if day.invalid?

          create_tee_groups(day, payload)

          create_flights(day, payload) if custom_flights?(payload)

          create_scoring_rules(day, payload)
        end

        update_free_tournaments

        url = league_tournament_path(league, tournament)

        SendEventToDripJob.perform_later('Created a new tournament', user: current_user, options: { tournament: { name: tournament.name } })
      else
        @errors << tournament.errors
      end
    end

    Rails.logger.info("Errors: #{@errors}")

    render json: { tournament_id: tournament.id, url: url, errors: @errors.to_json }
  end

  private

  def league
    league_from_user_for_league_id(params[:league_id])
  end

  def formatted_time(time_string)
    DateTime.parse(time_string)
  end

  def update_free_tournaments
    return if league.exempt_from_subscription
    return if league.free_tournaments_remaining.negative?

    league.update(free_tournaments_remaining: league.free_tournaments_remaining -= 1)
  end

  def course(course_id)
    Course.find(course_id)
  end

  def create_tournament_days(tournament, payload)
    day = TournamentDay.new(tournament: tournament,
                            course: course(payload['course_id']),
                            enter_scores_until_finalized: payload['enter_scores_until_finalized'],
                            tournament_at: formatted_time(payload['starts_at']))

    if day.save
      update_tournament_date(tournament)
    else
      @errors << day.errors
    end

    [day] # wrap in array for future multi-day
  end

  def create_tee_groups(tournament_day, payload)
    number_of_players = payload['number_of_players'].to_i
    groups_to_create = (number_of_players / 4.0).ceil
    tee_time = tournament_day.tournament_at

    groups_to_create.times do |_|
      TournamentGroup.create(tournament_day: tournament_day, max_number_of_players: 4, tee_time_at: tee_time)

      tee_time += 8.minutes
    end
  end

  def custom_flights?(payload)
    flight_data = payload['flights']
    return false if flight_data.count == 1 && flight_data.first['high_handicap'] == 300

    true
  end

  def create_flights(tournament_day, payload)
    flight_data = payload['flights']
    flight_data.each do |f|
      Flight.create(tournament_day: tournament_day,
                    flight_number: f['flight_number'],
                    lower_bound: f['low_handicap'],
                    upper_bound: f['high_handicap'],
                    course_tee_box_id: f['tee_box_id'])
    end
  end

  def create_scoring_rules(tournament_day, payload)
    rules = []

    scoring_rule_data = payload['scoring_rules']
    scoring_rule_data.each do |s|
      scoring_rule = s['class_name'].constantize.new(tournament_day: tournament_day)
      scoring_rule.is_opt_in = false

      if scoring_rule.save
        assign_custom_configuration(scoring_rule, s['custom_configuration'])
        assign_course_holes(scoring_rule, s['hole_configuration'])
        update_primary_scoring_rule(tournament_day)
        manage_shadow_stroke_play(tournament_day)

        create_payouts(scoring_rule, s['payouts'])

        rules << scoring_rule
      else
        @errors << scoring_rule.errors
      end
    end

    rules
  end

  def create_payouts(scoring_rule, payload)
    payouts = []

    payload.each do |p|
      flight = scoring_rule.tournament_day.flights.find_by(flight_number: p['flight_number'])

      payout = Payout.new(scoring_rule: scoring_rule,
                          flight: flight,
                          amount: p['amount'],
                          points: p['points'])

      if payout.save
        payouts << payout
      else
        @errors << payout.errors
      end
    end

    payouts
  end

  def assign_custom_configuration(scoring_rule, custom_config)
    scoring_rule.save_setup_details(custom_config)
  end

  def assign_course_holes(scoring_rule, hole_information)
    if hole_information == 'all_holes'
      holes = scoring_rule.tournament_day.course.course_holes
    elsif hole_information == 'front_nine'
      holes = scoring_rule.tournament_day.course.course_holes.where('hole_number < 10')
    elsif hole_information == 'back_nine'
      holes = scoring_rule.tournament_day.course.course_holes.where('hole_number > 9')
    elsif hole_information == 'custom'
      raise
    end

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
      r = tournament_day.scoring_rules.first
      r.primary_rule = true
      r.save
    end
  end

  def manage_shadow_stroke_play(tournament_day)
    TournamentService::ShadowStrokePlay.call(tournament_day)
  end
end
