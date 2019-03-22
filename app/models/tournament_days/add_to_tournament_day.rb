module AddToTournamentDay
  def add_player_to_group(tournament_group:, user:, paying_with_credit_card: false, confirmed: true, registered_by: nil)
    if self.tournament.includes_player?(user, self) == true
      Rails.logger.debug { "Player is Already Registered - Do Not Register Again. #{user.complete_name}" }

      return
    end

    outing = GolfOuting.create!(tournament_group: tournament_group, user: user, confirmed: confirmed, registered_by: registered_by)
    scorecard = Scorecard.create!(golf_outing: outing)

    flight = self.assign_user_to_flight(user: user)
    raise "No Flight for Player #{user.id} (#{user.complete_name})" if flight.blank?

    self.create_scores_for_scorecard(scorecard: scorecard)

    self.add_user_to_mandatory_scoring_rules(user: user)

    self.add_user_to_free_optional_scoring_rules(user: user)

    self.create_payment(user: user, paying_with_credit_card: paying_with_credit_card) if self == self.tournament.first_day

    user.send_silent_notification #ask device to update

    self.touch
  end

  ## Support Methods

  def create_payment(user:, paying_with_credit_card:)
  	payment_amount = self.tournament.dues_for_user(user, paying_with_credit_card) * -1.0

  	Payment.create(scoring_rule: self.scorecard_base_scoring_rule, payment_amount: payment_amount, user: user, payment_source: "Tournament Dues")
  end

  def create_scores_for_scorecard(scorecard:)
    self.scorecard_base_scoring_rule.course_holes.each_with_index do |hole, i|
      score = Score.create!(scorecard: scorecard, course_hole: hole, sort_order: i)
    end
  end

  def update_scores_for_scorecard(scorecard:)
    if self.scorecard_base_scoring_rule.course_holes.count != scorecard.scores.count
      scorecard.scores.destroy_all

      self.create_scores_for_scorecard(scorecard: scorecard)
    end
  end

  def add_user_to_mandatory_scoring_rules(user:)
    self.mandatory_scoring_rules.each do |rule|
      rule.users << user
    end
  end

  def add_user_to_free_optional_scoring_rules(user:)
    self.optional_scoring_rules.where(dues_amount: 0).each do |rule|
      rule.users << user
    end
  end

  def assign_course_tee_box_to_user(user:, flight:)
    golf_outing = self.golf_outing_for_player(user)

    if flight.blank? == false && golf_outing.blank? == false
      golf_outing.course_tee_box = flight.course_tee_box
      golf_outing.save
    end
  end

end