module Addable
  extend ActiveSupport::Concern

  def add_player_to_group(tournament_group, user, paying_with_credit_card = false, confirmed = true, registered_by = nil)
    if self.tournament.includes_player?(user, self) == true
      Rails.logger.info { "Player is Already Registered - Do Not Register Again. #{user.complete_name}" }

      return
    end

    Rails.logger.debug { "Adding to Group" }

    outing = GolfOuting.create!(tournament_group: tournament_group, user: user, confirmed: confirmed, registered_by: registered_by)
    scorecard = Scorecard.create!(golf_outing: outing)

    Rails.logger.debug { "Added to Group" }

    self.assign_player_to_flight(user)
    flight = self.flight_for_player(user)
    raise "No Flight for Player #{user.id} (#{user.complete_name})" if flight.blank?

    self.create_scores_for_scorecard(scorecard)

    self.add_player_to_free_contests(user)

    if self == self.tournament.first_day
      Payment.create(tournament: self.tournament, payment_amount: self.tournament.dues_for_user(user, paying_with_credit_card) * -1.0, user: user, payment_source: "Tournament Dues")
    end

    user.send_silent_notification #ask device to update

    self.touch
  end

  def create_scores_for_scorecard(scorecard)
    self.course_holes.each_with_index do |hole, i|
      score = Score.create!(scorecard: scorecard, course_hole: hole, sort_order: i)
    end
  end

  def update_scores_for_scorecard(scorecard)
    if self.course_holes.count != scorecard.scores.count
      scorecard.scores.destroy_all

      self.create_scores_for_scorecard(scorecard)
    end
  end

  def remove_player_from_group(tournament_group, user, remove_from_teams = false)
    Tournament.transaction do
      tournament_group.golf_outings.each do |outing|
        Rails.cache.write(tournament_group.tournament_day.scorecard_id_cache_key(outing.user), nil)

        if user.id == outing.scorecard.designated_editor_id
          outing.scorecard.designated_editor_id = nil
          outing.scorecard.save
        end

        if outing.user == user
          outing.destroy
          break
        end
      end

      #remove from flight
      flight = self.flight_for_player(user)
      flight.users.delete(user) unless flight.blank?

      #remove from teams
      if remove_from_teams == true
        Rails.logger.debug { "Removing Player from Teams" }

        tournament_group.golfer_teams.each do |team|
          if team.users.include? user
            team.users.destroy(user)
          end
        end
      end

      #contests
      self.tournament.tournament_days.each do |d|
        d.contests.each do |c|
          c.remove_user(user)
        end
      end

      #tournament credit
      if self == self.tournament.first_day
        previous_payments = Payment.where(user: user, tournament: self.tournament).where("payment_amount < 0")
        previous_unrefunded_payments = previous_payments.select{|item| item.credits.count == 0}
        total_unrefunded_payment_amount = previous_unrefunded_payments.map(&:payment_amount).sum

        Rails.logger.debug { "Unrefunded Amount: #{total_unrefunded_payment_amount} From # of Transactions: #{previous_unrefunded_payments.count}" }

        refund = Payment.create(tournament: self.tournament, payment_amount: total_unrefunded_payment_amount * -1.0, user: user, payment_source: "Tournament Dues Credit")

        previous_unrefunded_payments.each do |p|
          p.credits << refund
          p.save
        end
      end
    end
  end

  def add_player_to_free_contests(user)
    self.tournament.tournament_days.each do |d|
      d.contests.each do |c|
        c.add_user(user) if c.is_opt_in == false
      end
    end
  end

  def player_course_handicap_for_player(p, f = nil)
    player_course_handicap = 0

    golf_outing = self.golf_outing_for_player(p) #in multi-day with manual registration, might not match
    unless golf_outing.blank?
      golf_outing.scorecard.set_course_handicap(true) if self.golf_outing_for_player(p).course_handicap == 0 #re-calc handicap if we do not have one
      player_course_handicap = self.golf_outing_for_player(p).course_handicap

      unless f.blank?
        if golf_outing.course_handicap == 0 #re-calc handicap if we do not have one
          Rails.logger.debug { "Re-Calculating Course Handicap AGAIN for #{p.complete_name}" }

          golf_outing.scorecard.set_course_handicap(true) unless golf_outing.scorecard.blank?

          player_course_handicap = p.course_handicap_for_golf_outing(golf_outing, f)

          golf_outing.course_handicap = player_course_handicap
          golf_outing.save
        end
      else
        Rails.logger.debug { "Not Setting Course Handicap - Player Not Flighted #{p.complete_name}" }
      end

      Rails.logger.debug { "Player Course Handicap for Course/Outing: #{player_course_handicap}" }
    end

    return player_course_handicap
  end

  def team_course_handicap_for_player(player)
    team = self.golfer_team_for_player(player)

    unless team.blank?
      highest_handicap = 0

      team.users.each do |u|
        player_course_handicap = self.player_course_handicap_for_player(u)

        if player_course_handicap.blank?
          Rails.logger.info { "team_course_handicap_for_player: Player Course Handicap Was Blank: #{u.id}" }

          return 0
        else
          highest_handicap = player_course_handicap if player_course_handicap > highest_handicap #the highest one is returned
        end
      end

      return highest_handicap
    else
      return 0
    end
  end

  def assign_players_to_flights(should_destroy_results = true)
    self.tournament_day_results.destroy_all if should_destroy_results == true #clear calculated results

    self.reload

    if self.tournament.league.allow_scoring_groups
      self.assign_players_to_flights_from_scoring_groups
    else
      self.tournament.players_for_day(self).each do |p|
        self.assign_player_to_flight(p)
      end
    end

    self.touch #bust the cache, yo.
  end

  def assign_players_to_flights_from_scoring_groups
    self.flights.each do |f|
      f.users.clear

      Rails.logger.info { "Adding Users From Scoring Group to Flight" }

      f.league_season_scoring_group.users.each do |u|
        f.users << u if self.tournament.players_for_day(self).include? u
      end
    end
  end

  def assign_player_to_flight(player)
    self.flights.each do |f|
      f.users.delete(player)

      course_handicap = self.usable_handicap_for_player(player, f)

      unless course_handicap.blank?
        if course_handicap >= f.lower_bound && course_handicap <= f.upper_bound
          f.users << player

          Rails.logger.info { "Flighted: #{course_handicap} (#{f.lower_bound} to #{f.upper_bound}) for Player: #{player.id} #{player.complete_name} for Flight Num #{f.flight_number}" }
        else
          Rails.logger.debug { "NOT Flighted: #{course_handicap} (#{f.lower_bound} to #{f.upper_bound}) for Player: #{player.id} #{player.complete_name} for Flight Num #{f.flight_number}" }
        end
      else
        Rails.logger.debug { "Flighting - Player Course Handicap Blank: #{player.id} #{player.complete_name}" }
      end
    end

    assigned_flight = self.flight_for_player(player)

    if assigned_flight == nil
      Rails.logger.info { "Adding Player to Last Flight - Not Normally Flighted" }

      last_flight = self.flights.last #add the player to the 'last' flight
      last_flight.users << player unless last_flight.blank?

      assigned_flight = last_flight
    end

    self.assign_course_tee_box_to_player(player, assigned_flight)

    assigned_flight
  end

  def usable_handicap_for_player(player, flight)
    player_course_handicap = self.player_course_handicap_for_player(player, flight)
    team_course_handicap = self.team_course_handicap_for_player(player)

    Rails.logger.info { "Flighting - Player HCP: #{player_course_handicap} Team HCP: #{team_course_handicap} - #{player.complete_name}. Checking against Flight #{flight.flight_number}" }

    player_course_handicap = team_course_handicap if team_course_handicap > player_course_handicap #the highest handicap is the one used if this is a team

    player_course_handicap
  end

  def assign_course_tee_box_to_player(player, flight)
    golf_outing = self.golf_outing_for_player(player)

    if flight.blank? == false && golf_outing.blank? == false
      golf_outing.course_tee_box = flight.course_tee_box
      golf_outing.save

      Rails.logger.debug { "Golf Outing Saved" }
    end
  end

end
