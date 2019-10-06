module Play::TournamentsHelper
  def team_name(scoring_rule, tournament_group, index)
    return '' if scoring_rule.team_type == ScoringRuleTeamType::NONE

    slots = []

    tournament_group.daily_teams.each_with_index do |t, i|
      slot = []

      t.max_players.times do
        slot << i
      end

      slots << slot
    end

    flattened_array = slots.flatten

    if flattened_array.count >= (index + 1)
      return "(Team #{flattened_array[index] + 1})"
    else
      return ''
    end
  end

  def points_or_blank(day, user)
    points = day.points_for_user(user: user)
    points.positive? ? points.to_i : '0'
  end

  def format_winners(winners)
    return '' if winners.blank?

    html = ''

    winners.each_with_index do |winner, i|
      html << winner[:name] unless winner[:name].blank?

      html << "<br/>" unless i == winners.count - 1
    end

    return html.html_safe
  end

  def format_payout(winners)
    return "" if winners.blank?

    html = ""

    winners.each_with_index do |winner, i|
      html << number_to_currency(winner[:amount])

      html << "<br/>" unless i == winners.count - 1
    end

    return html.html_safe
  end

  def format_points(winners)
    return "" if winners.blank?

    html = ""

    winners.each_with_index do |winner, i|
      if winner[:points].blank?
        html << "0"
      else
        html << winner[:points].to_s
      end

      html << "<br/>" unless i == winners.count - 1
    end

    return html.html_safe
  end

  def format_results(winners)
    return "" if winners.blank?

    html = ""

    winners.each_with_index do |winner, i|
      html << winner[:result_value]

      html << "<br/>" unless i == winners.count - 1
    end

    return html.html_safe
  end

  def display_tee_time_or_position(tournament_group)
    if tournament_group.tournament_day.tournament.show_players_tee_times == true
      return tournament_group.tee_time_at.to_s(:time_only)
    else
      return tournament_group.time_description
    end
  end

  def league_season_result_is_winner?(result, matchup)
    result.league_season_team == matchup.winning_team
  end

end
