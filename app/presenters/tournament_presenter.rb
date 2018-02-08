class TournamentPresenter
  include ActionView::Helpers::UrlHelper

  attr_accessor :tournament
  attr_accessor :tournament_day
  attr_accessor :user
  attr_accessor :day_flights
  attr_accessor :combined_flights

  def initialize args
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def name
    self.tournament.name
  end

  def number_of_days
    self.tournament.tournament_days.count
  end

  def day_name
    self.tournament_day.blank? ? "Final" : self.tournament_day.pretty_day(false)
  end

  def day_cache_key
    self.tournament_day.blank? ? nil : self.tournament_day
  end

  def player_count
    self.tournament.number_of_players
  end

  def finalized?
    self.tournament.is_finalized
  end

  def date_and_times
    dates = ""

    self.tournament.tournament_days.each do |day|
      dates << day.tournament_at.to_s(:date_and_time) << "<br/>"
    end

    dates.html_safe
  end

  def course_names
    names = ""

    self.tournament.courses.each do |course|
      names << course.name << "<br/>"
    end

    names.html_safe
  end

  def course_locations
    locations = ""

    self.tournament.courses.each do |course|
      unless course.street_address_1.blank?
        locations << "<p>"
        locations << course.street_address_1 << "<br/>"
        locations << course.city << ", " << course.us_state << " " << course.postal_code << "<br/>"
        locations << link_to("View on Map", "https://www.google.com/maps/place/#{course.street_address_1}+#{course.city}+#{course.us_state}+#{course.postal_code}")
        locations << "</p>"
      end
    end

    locations.html_safe
  end

  def day_links
    links = []

    self.tournament.tournament_days.each do |day|
      highlighted = day == self.tournament_day

      links << {name: day.pretty_day, link: Rails.application.routes.url_helpers.play_tournament_path(self.tournament, tournament_day: day), highlighted: highlighted}
    end

    links << {name: "Final", link: Rails.application.routes.url_helpers.play_tournament_path(self.tournament), highlighted: self.tournament_day == nil} if self.tournament.tournament_days.count > 1

    links
  end

  def signup_open
    self.tournament.signup_opens_at.to_s(:date_and_time)
  end

  def signup_close
    self.tournament.signup_closes_at.to_s(:date_and_time)
  end

  ##

  def day_is_playable?
    self.tournament_day.blank? ? false : self.tournament_day.can_be_played?
  end

  def day_has_golfer_teams?
    self.tournament_day.blank? ? false : self.tournament_day.golfer_teams.count > 0
  end

  def day_has_scores?
    if self.tournament_day.blank?
      self.tournament.tournament_days.last.has_scores?
    else
      self.tournament_day.has_scores?
    end
  end

  def includes_user?
    self.tournament_day.blank? ? self.tournament.includes_player?(self.user, self.tournament.tournament_days.first) : self.tournament.includes_player?(self.user, self.tournament_day)
  end

  def showing_final?
    self.tournament_day.blank?
  end

  def leaderboard_link
    day = self.tournament_day.blank? ? self.tournament.tournament_days.last : self.tournament_day

    Rails.application.routes.url_helpers.play_tournament_leaderboard_path(self.tournament, day: day)
  end

  def scorecard_link
    Rails.application.routes.url_helpers.play_scorecard_path(self.tournament_day.primary_scorecard_for_user(self.user)) unless self.tournament_day.primary_scorecard_for_user(self.user).blank?
  end

  def user_paid?
    self.tournament.user_has_paid?(self.user)
  end

  def user_confirmed?
    self.tournament_day.player_is_confirmed?(self.user)
  end

  def user_score
    self.tournament_day.player_score(self.user)
  end

  def user_can_register_for_contests?
    return false if self.tournament_day.blank?

    self.tournament.is_past? == false && self.tournament_day.contests.count > 0 && self.tournament.includes_player?(self.user, self.tournament_day) && self.tournament_day.can_be_played?
  end

  def contest_signup_link
    Rails.application.routes.url_helpers.play_tournament_tournament_day_contests_path(self.tournament, self.tournament_day)
  end

  ##

  def selected_day_has_payouts?
    if self.tournament_day == nil
      true
    else
      self.tournament_day.has_payouts?
    end
  end

  def tournament_players
    return [] if self.tournament_day.blank?

    if self.day_has_golfer_teams?
      teams = []

      self.tournament_day.golfer_teams.each do |golfer_team|
        group = golfer_team.users.blank? ? nil : self.tournament_day.tournament_group_for_player(golfer_team.users.first)

        teams << {name_data: golfer_team, group: group, id: nil}
      end

      teams
    else
      groups = []

      self.tournament_day.tournament_groups.each_with_index do |tournament_group, i|
        outings = []

        tournament_group.golf_outings.each do |golf_outing|
          flight = tournament_day.flight_for_player(golf_outing.user).blank? ? nil : tournament_day.flight_for_player(golf_outing.user)
          name = golf_outing.user.blank? ? "Error" : golf_outing.user.complete_name
          user_id = golf_outing.user.blank? ? nil : golf_outing.user.id

          outings << {name: name, id: user_id, handicap: golf_outing.course_handicap.to_i, flight: flight, group: tournament_group}
        end

        groups << outings
      end

      groups
    end
  end

  def flights_with_rankings
    if self.tournament_day == nil
      return self.combined_flights
    else
      return self.day_flights
    end
  end

  def payouts
    flights_with_payouts = []

    if self.tournament_day == nil
      self.tournament.tournament_days.each do |d|
        d.flights.each do |f|
          payouts = []

          f.payout_results.each do |p|
            username = p.user.blank? ? "" : p.user.complete_name
            user_id = p.user.blank? ? nil : p.user.id

            payouts << {flight_number: f.flight_number.to_i, name: username, amount: p.amount, points: p.points.to_i, user_id: user_id}
          end

          flights_with_payouts << {payouts: payouts} unless payouts.blank?
        end
      end
    else
      self.tournament_day.flights.each do |f|
        payouts = []

        f.payout_results.each do |p|
          username = p.user.blank? ? "" : p.user.complete_name
          user_id = p.user.blank? ? nil : p.user.id

          payouts << {flight_number: f.flight_number.to_i, name: username, amount: p.amount, points: p.points.to_i, user_id: user_id}
        end

        flights_with_payouts << {payouts: payouts}
      end
    end

    flights_with_payouts
  end

  def contests
    items = []

    if self.tournament_day == nil
      self.tournament.tournament_days.each do |d|
        d.contests.order(:name).each do |c|
          items << {name: c.name, winners: c.winners}
        end
      end
    else
      self.tournament_day.contests.order(:name).each do |c|
        items << {name: c.name, winners: c.winners}
      end
    end

    items
  end

  def day_cache_key(prefix)
    if self.tournament_day.blank?
      max_updated_at = DateTime.now.try(:utc).try(:to_s, :number)
      cache_key = "tournament_days/#{prefix}-#{max_updated_at}"
    else
      max_updated_at = tournament_day.updated_at.try(:utc).try(:to_s, :number)
      cache_key = "tournament_days/#{prefix}-#{tournament_day.id}-#{max_updated_at}"
    end
  end

end
