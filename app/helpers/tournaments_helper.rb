module TournamentsHelper

  def is_editable?(tournament)
    return true if tournament.league.try(:membership_for_user, current_user).try(:is_admin)

    return true if current_user.is_super_user?

    return false
  end

  def is_today?(tournament)
    return false if tournament.tournament_days.count == 0

    if tournament.first_day.tournament_at >= Time.zone.now.at_beginning_of_day && tournament.last_day.tournament_at < Time.zone.now.at_end_of_day
      return true
    else
      return false
    end
  end

  def split_scores_for_scorecard(scorecard, number_of_holes)
    return scorecard.scores.each_slice(number_of_holes / 2).to_a
  end

  def split_holes_for_course_tournament(tournament)
    return tournament.course_holes.each_slice(tournament.course_holes.count / 2).to_a
  end

  def team_name_for_player(player, tournament_day)
    return "N/A" if tournament_day.tournament.display_teams? == false

    team = tournament_day.golfer_team_for_player(player)

    if team.blank?
      return "-"
    else
      return "#{team.try(:name)}"
    end
  end

  def flight_number_for_player_in_tournament_day(tournament_day, player)
    flight = @tournament_day.flight_for_player(player)

    unless flight.blank?
      return flight.flight_number
    else
      return "Needs Re-Flighting"
    end
  end

end
