module AddToTournamentDay
  def add_player_to_group(tournament_group:, user:, paying_with_credit_card: false, confirmed: true, registered_by: nil)
    if tournament.includes_player?(user, self) == true
      Rails.logger.debug { "Player is Already Registered - Do Not Register Again. #{user.complete_name}" }

      return
    end

    outing = GolfOuting.create!(tournament_group: tournament_group, user: user, confirmed: confirmed, registered_by: registered_by)
    scorecard = Scorecard.create!(golf_outing: outing)

    flight = assign_user_to_flight(user: user)
    raise "No Flight for Player #{user.id} (#{user.complete_name})" if flight.blank?

    create_scores_for_scorecard(scorecard: scorecard)

    add_user_to_mandatory_scoring_rules(user: user)

    add_user_to_free_optional_scoring_rules(user: user)

    create_payment(user: user, paying_with_credit_card: paying_with_credit_card) if self == tournament.first_day

    enable_team_user(user: user)

    add_user_to_daily_team(tournament_group, user)

    user.send_silent_notification({ action: 'update', tournament_id: tournament.id, tournament_day_id: id })

    touch
  end

  ## Support Methods

  def create_payment(user:, paying_with_credit_card:)
    payment_amount = tournament.dues_for_user(user, paying_with_credit_card) * -1.0

    Payment.create(scoring_rule: scorecard_base_scoring_rule, payment_amount: payment_amount, user: user, payment_source: 'Tournament Dues')
  end

  def create_scores_for_scorecard(scorecard:)
    scorecard_base_scoring_rule.course_holes.each_with_index do |hole, i|
      Score.create!(scorecard: scorecard, course_hole: hole, sort_order: i)
    end
  end

  def update_scores_for_scorecard(scorecard:)
    scorecard_base_scoring_rule.course_holes.each_with_index do |hole, i|
      existing_score = scorecard.scores.find_by(course_hole: hole)
      if existing_score.present?
        existing_score.update(sort_order: i)
      else
        Score.create!(scorecard: scorecard, course_hole: hole, sort_order: i)
      end
    end

    scorecard.scores.where.not(course_hole: scorecard_base_scoring_rule.course_holes).destroy_all
  end

  def add_user_to_daily_team(group, user)
    return if group.daily_teams.count.zero?

    group.daily_teams.each do |team|
      next if team.full?

      team.users << user
      break
    end
  end

  def add_user_to_mandatory_scoring_rules(user:)
    mandatory_scoring_rules.each do |rule|
      rule.users << user unless rule.users.include? user
    end
  end

  def add_user_to_free_optional_scoring_rules(user:)
    optional_scoring_rules.where(dues_amount: 0).find_each do |rule|
      rule.users << user unless rule.users.include? user
    end
  end

  def enable_team_user(user:)
    matchup = league_season_team_matchup_for_player(user)
    matchup.include_user(user) if matchup.present?
  end

  def assign_course_tee_box_to_user(user:, flight:)
    golf_outing = golf_outing_for_player(user)

    if flight.present? && golf_outing.present?
      golf_outing.course_tee_box = flight.course_tee_box
      golf_outing.save
    else
      raise "Could not assign course tee box to user #{user&.id} #{flight&.id} #{golf_outing&.id}" # TODO: Remove once we learn more.
    end
  end
end
