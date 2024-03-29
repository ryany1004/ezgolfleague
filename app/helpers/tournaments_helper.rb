module TournamentsHelper
  def is_today?(tournament)
    return false if tournament.tournament_days.count == 0

    if tournament.first_day.tournament_at >= Time.zone.now.at_beginning_of_day && tournament.last_day.tournament_at < Time.zone.now.at_end_of_day
      return true
    else
      return false
    end
  end

  def split_scores_for_scorecard(scorecard, number_of_holes)
    if number_of_holes <= 9
      return scorecard.scores.each_slice(number_of_holes).to_a
    else
      return scorecard.scores.each_slice(number_of_holes / 2).to_a
    end
  end

  def split_holes_for_course_tournament_day(tournament_day)
    course_holes = tournament_day.scorecard_base_scoring_rule.course_holes

    if course_holes.count <= 9
      return course_holes.each_slice(course_holes.count).to_a
    else
      return course_holes.each_slice(course_holes.count / 2).to_a
    end
  end

  def team_name_for_player(player, scoring_rule)
    return "N/A" if scoring_rule.team_type != ScoringRuleTeamType::DAILY

    team = scoring_rule.tournament_day.daily_team_for_player(player)

    if team.blank?
      return "-"
    else
      return team.try(:name)
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
