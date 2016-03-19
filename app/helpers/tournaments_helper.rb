module TournamentsHelper

  def is_editable?(tournament)
    return true if params[:debug_mode] == true
    
    return false if tournament.blank?

    if is_today?(tournament)
      return false
    else
      return true
    end
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

end
