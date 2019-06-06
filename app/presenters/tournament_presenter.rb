class TournamentPresenter
  include ActionView::Helpers::UrlHelper

  attr_accessor :tournament
  attr_accessor :tournament_day
  attr_accessor :user
  attr_accessor :day_flights
  attr_accessor :combined_flights
  attr_accessor :show_combined

  def initialize(args)
    args.each do |k, v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def name
    tournament.name
  end

  def number_of_days
    tournament.tournament_days.count
  end

  def day_name
    tournament_day.blank? ? 'Final' : tournament_day.pretty_day(false)
  end

  def ranking_name
    tournament_day.scorecard_base_scoring_rule.name
  end

  def player_count
    tournament.number_of_players
  end

  def finalized?
    tournament.is_finalized
  end

  def scoring_rules
    tournament_day.scoring_rules
  end

  def date_and_times
    dates = ''

    tournament.tournament_days.each do |day|
      dates << day.tournament_at.to_s(:date_and_time) << '<br/>'
    end

    dates.html_safe
  end

  def course_names
    names = ''

    tournament.courses.each do |course|
      names << course.name << '<br/>'
    end

    names.html_safe
  end

  def course_locations
    locations = ''

    tournament.courses.each do |course|
      next if course.street_address_1.blank?

      locations << '<p>'
      locations << course.street_address_1 << '<br/>'
      locations << course.city << ', ' << course.us_state << ' ' << course.postal_code << '<br/>'
      locations << link_to('View on Map', "https://www.google.com/maps/place/#{course.street_address_1}+#{course.city}+#{course.us_state}+#{course.postal_code}")
      locations << '</p>'
    end

    locations.html_safe
  end

  def day_links
    links = []

    tournament.tournament_days.each do |day|
      highlighted = (day == tournament_day) && !show_combined

      links << { name: day.pretty_day,
                 link: Rails.application.routes.url_helpers.play_tournament_path(tournament, tournament_day: day),
                 highlighted: highlighted }
    end

    links << { name: 'Final',
               link: Rails.application.routes.url_helpers.play_tournament_path(tournament, combined: true),
               highlighted: show_combined } if tournament.tournament_days.count.positive?

    links
  end

  def signup_open
    tournament.signup_opens_at.to_s(:date_and_time)
  end

  def signup_close
    tournament.signup_closes_at.to_s(:date_and_time)
  end

  def flight_or_group_name
    if tournament.has_league_season_team_scoring_rules?
      'Team'
    elsif tournament.league.allow_scoring_groups
      'Group'
    else
      'Flight'
    end
  end

  def day_is_playable?
    tournament_day.blank? ? false : tournament_day.can_be_played?
  end

  def day_has_league_teams?
    tournament_day.scoring_rules.any? { |x| x.team_type == ScoringRuleTeamType::LEAGUE }
  end

  def day_has_daily_teams?
    tournament_day.blank? ? false : tournament_day.daily_teams.count.positive?
  end

  def day_has_scores?
    if tournament_day.blank?
      tournament.tournament_days.last.has_scores?
    else
      tournament_day.has_scores?
    end
  end

  def show_aggregated_results?
    tournament_day.scorecard_base_scoring_rule.has_aggregated_results?
  end

  def includes_user?
    tournament_day.blank? ? tournament.includes_player?(user, tournament.tournament_days.first) : tournament.includes_player?(user, tournament_day)
  end

  def showing_final?
    show_combined
  end

  def leaderboard_link
    day = tournament_day.presence || tournament.tournament_days.last

    Rails.application.routes.url_helpers.play_tournament_leaderboard_path(tournament, day: day)
  end

  def scorecard_link
    Rails.application.routes.url_helpers.play_scorecard_path(tournament_day.primary_scorecard_for_user(user)) if tournament_day.primary_scorecard_for_user(user).present?
  end

  def user_paid?
    tournament.user_has_paid?(user)
  end

  def user_confirmed?
    tournament_day.player_is_confirmed?(user)
  end

  def user_score
    tournament_day.player_score(user)
  end

  def user_can_register_for_scoring_rules?
    return false if tournament_day.blank?

    !finalized? && !tournament.is_past? && tournament_day.scoring_rules.count.positive? && tournament.includes_player?(user, tournament_day) && tournament_day.can_be_played?
  end

  def scoring_rule_signup_link
    Rails.application.routes.url_helpers.play_tournament_tournament_day_scoring_rules_path(tournament, tournament_day)
  end

  def selected_day_has_payouts?
    if tournament_day.blank?
      true
    else
      tournament_day.has_payouts?
    end
  end

  def payouts
    payout_details = []

    if tournament_day.blank?
      days = tournament.tournament_days
    else
      days = tournament.tournament_days.where(id: tournament_day.id)
    end

    days.each do |day|
      day.mandatory_scoring_rules.each do |rule|
        rule.payout_results.each do |result|
          user_id = result.user.blank? ? nil : result.user.id
          flight_number = result.flight.blank? ? 1 : result.flight.flight_number.to_i
          flight_name = result.flight.blank? ? nil : result.flight.display_name

          payout_details <<
            {
              flight_number: flight_number,
              flight_name: flight_name,
              name: result.name,
              amount: result.amount,
              points: result.points.to_i,
              user_id: user_id,
              matchup_position: result.team_matchup_designator
            }
        end
      end
    end

    payout_details
  end

  def optional_scoring_rules_with_dues
    items = []

    if tournament_day.blank?
      tournament.optional_scoring_rules_with_dues.each do |r|
        items << { name: r.name, winners: r.legacy_contest_winners } if r.legacy_contest_winners.present?
      end
    else
      tournament_day.optional_scoring_rules_with_dues.each do |r|
        items << { name: r.name, winners: r.legacy_contest_winners } if r.legacy_contest_winners.present?
      end
    end

    items
  end

  def tournament_players
    return [] if tournament_day.blank?

    if day_has_league_teams?
      league_teams_players
    elsif day_has_daily_teams?
      daily_teams_players
    else
      individual_players
    end
  end

  def individual_players
    groups = []

    tournament_day.tournament_groups.each do |tournament_group|
      outings = []

      tournament_group.golf_outings.each do |golf_outing|
        flight = tournament_day.flight_for_player(golf_outing.user).presence
        name = golf_outing.user.blank? ? 'Error' : golf_outing.user.complete_name
        user_id = golf_outing.user.blank? ? nil : golf_outing.user.id

        next if flight.blank?

        outings << { name: name,
                     id: user_id,
                     handicap: golf_outing.course_handicap.to_i,
                     flight: flight,
                     scoring_group_name: flight.league_season_scoring_group&.name,
                     group: tournament_group }
      end

      groups << outings
    end

    groups
  end

  def league_teams_players
    teams = []

    tournament_day.league_season_team_tournament_day_matchups.each do |matchup|
      teams << { name: matchup.name }
    end

    teams
  end

  def daily_teams_players
    teams = []

    tournament_day.daily_teams.each do |daily_team|
      group = daily_team.users.blank? ? nil : tournament_day.tournament_group_for_player(daily_team.users.first)

      teams << { name_data: daily_team, group: group, id: nil } if group.present?
    end

    teams
  end

  def flights_with_rankings
    if show_combined
      combined_flights
    else
      day_flights
    end
  end

  def team_matchups
    tournament_day.league_season_team_tournament_day_matchups
  end

  def day_cache_key(prefix)
    if tournament_day.blank?
      max_updated_at = Time.zone.now.try(:utc).try(:to_s, :number)
      "tournament_days/#{prefix}-#{max_updated_at}"
    else
      max_updated_at = tournament_day.updated_at.try(:utc).try(:to_s, :number)
      "tournament_days/#{prefix}-#{tournament_day.id}-#{max_updated_at}"
    end
  end
end
