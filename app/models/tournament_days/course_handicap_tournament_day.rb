module CourseHandicapTournamentDay
  def player_course_handicap_for_user(user:, flight: nil)
    player_course_handicap = 0

    golf_outing = self.golf_outing_for_player(user) #in multi-day with manual registration, might not match
    unless golf_outing.blank?
      golf_outing.scorecard&.set_course_handicap(true) if self.golf_outing_for_player(user).course_handicap == 0 #re-calc handicap if we do not have one
      player_course_handicap = self.golf_outing_for_player(user).course_handicap

      unless flight.blank?
        if golf_outing.course_handicap == 0 #re-calc handicap if we do not have one
          Rails.logger.debug { "Re-Calculating Course Handicap AGAIN for #{user.complete_name}" }

          golf_outing&.scorecard&.set_course_handicap(true)

          player_course_handicap = user.course_handicap_for_golf_outing(golf_outing, flight)
          golf_outing.course_handicap = player_course_handicap
          golf_outing.save
        else
          Rails.logger.debug { "golf_outing.course_handicap is not zero" }
        end
      else
        Rails.logger.debug { "Not Setting Course Handicap - Player Not Flighted #{user.complete_name}" }
      end

      Rails.logger.debug { "Player Course Handicap for Course/Outing: #{player_course_handicap}" }
    end

    player_course_handicap
  end

  #TEAM: UPDATE
  def team_course_handicap_for_user(user:)
    team = self.golfer_team_for_player(user)

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

      highest_handicap
    else
      0
    end
  end

  def usable_handicap_for_user(user:, flight:)
    player_course_handicap = self.player_course_handicap_for_user(user: user, flight: flight)
    team_course_handicap = self.team_course_handicap_for_user(user: user)

    Rails.logger.info { "Flighting - Player HCP: #{player_course_handicap} Team HCP: #{team_course_handicap} - #{user.complete_name}. Checking against Flight #{flight.flight_number}" }

    player_course_handicap = team_course_handicap if team_course_handicap > player_course_handicap #the highest handicap is the one used if this is a team

    player_course_handicap
  end
end