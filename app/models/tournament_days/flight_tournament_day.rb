module FlightTournamentDay
  def assign_users_to_flights(should_destroy_results: true)
    if should_destroy_results
      self.scoring_rules.each do |r|
        r.tournament_day_results.where("flight_id IS NOT NULL").destroy_all
      end
    end

    self.reload

    if self.tournament.league.allow_scoring_groups
      self.assign_users_to_flights_from_scoring_groups
    else
      self.tournament.players_for_day(self).each do |p|
        self.assign_user_to_flight(user: p)
      end
    end

    self.touch # bust the cache, yo.
  end

  def assign_users_to_flights_from_scoring_groups
    self.flights.each do |f|
      f.users.clear

      Rails.logger.info { "Adding Users From Scoring Group to Flight" }

      f.league_season_scoring_group.users.each do |u|
        f.users << u if self.tournament.players_for_day(self).include? u
      end
    end
  end

  def assign_user_to_flight(user:)
    self.flights.each do |f|
      f.users.delete(user)

      course_handicap = self.usable_handicap_for_user(user: user, flight: f)

      unless course_handicap.blank?
        if course_handicap >= f.lower_bound && course_handicap <= f.upper_bound
          f.users << user

          Rails.logger.info { "Flighted: #{course_handicap} (#{f.lower_bound} to #{f.upper_bound}) for Player: #{user.id} #{user.complete_name} for Flight Num #{f.flight_number}" }
        else
          Rails.logger.debug { "NOT Flighted: #{course_handicap} (#{f.lower_bound} to #{f.upper_bound}) for Player: #{user.id} #{user.complete_name} for Flight Num #{f.flight_number}" }
        end
      else
        Rails.logger.debug { "Flighting - Player Course Handicap Blank: #{user.id} #{user.complete_name}" }
      end
    end

    assigned_flight = self.flight_for_player(user)

    if assigned_flight == nil
      Rails.logger.info { "Adding Player to Last Flight - Not Normally Flighted" }

      last_flight = self.flights.last #add the player to the 'last' flight
      last_flight.users << user unless last_flight.blank?

      assigned_flight = last_flight
    end

    self.assign_course_tee_box_to_user(user: user, flight: assigned_flight)

    assigned_flight
  end
end