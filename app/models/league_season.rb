module LeagueSeasonType
  INDIVIDUAL = 0
  TEAM = 1
end

class LeagueSeason < ApplicationRecord
  belongs_to :league, touch: true, inverse_of: :league_seasons

  has_many :league_season_teams, dependent: :destroy
  has_many :payments, inverse_of: :league_season
  has_many :subscription_credits, -> { order 'created_at DESC' }
  has_many :league_season_scoring_groups, -> { order 'name' }, inverse_of: :league_season, dependent: :destroy
  has_many :league_season_ranking_groups, -> { order 'name' }, inverse_of: :league_season, dependent: :destroy

  validates :name, :starts_at, :ends_at, :league, presence: true

  validate :dates_are_valid
  def dates_are_valid
    if starts_at.present? && ends_at.present? && starts_at > ends_at
      errors.add(:ends_at, "can't be before the starting date")
    end

    if starts_at.present? && ends_at.present? && ends_at < starts_at
      errors.add(:starts_at, "can't be after the ending date")
    end
  end

  validate :one_year_maximum
  def one_year_maximum
    if (ends_at - starts_at).to_i > (367 * 60 * 60 * 24)
      errors.add(:ends_at, "can't be before more than a year after the starting date")
    end
  end

  validate :does_not_overlap
  def does_not_overlap
    if starts_at.blank? || ends_at.blank?
      errors.add(:starts_at, "cannot validate an empty value")
      errors.add(:ends_at, "cannot validate an empty value")

      return
    end

    other_league_seasons = self.league.league_seasons
    other_league_seasons.each do |s|
      return if s == self

      if s.starts_at < self.starts_at && s.ends_at > self.starts_at
        errors.add(:starts_at, "can't be in inside the range of an existing season for this league")
      end

      if s.starts_at < self.ends_at && s.ends_at > self.ends_at
        errors.add(:ends_at, "can't be in inside the range of an existing season for this league")
      end
    end
  end

  def tournaments
    Tournament.tournaments_happening_at_some_point(self.starts_at, self.ends_at, [self.league], true)
  end

  def season_type
    if self.season_type_raw == 1
      LeagueSeasonType::TEAM
    else
      LeagueSeasonType::INDIVIDUAL
    end
  end

  def is_teams?
    self.season_type_raw == LeagueSeasonType::TEAM
  end

  def paid_active_golfers
    sum_paid = 0

    self.subscription_credits.each do |s|
      sum_paid += s.golfer_count
    end

    sum_paid
  end

  def users_not_in_scoring_groups
    users_not_in_groups = []

    self.league.users.each do |u|
      user_is_in_any_group = false

      self.league_season_scoring_groups.each do |g|
        user_is_in_any_group = true if g.users.include? u
      end

      users_not_in_groups << u unless user_is_in_any_group
    end

    users_not_in_groups
  end

  def users_not_in_teams
    users_not_in_t = []

    self.league.users.each do |u|
      user_is_in_any_team = false

      self.league_season_teams.each do |g|
        user_is_in_any_team = true if g.users.include? u
      end

      users_not_in_t << u unless user_is_in_any_team
    end

    users_not_in_t
  end

  def complete_name
    "#{self.name} (#{self.league.name})"
  end

  def user_has_paid?(user)
    if self.dues_amount.zero?
      true
    else
      payments = self.payments.where(user: user).where('payment_amount > 0').where('payment_type = ?', "#{user.complete_name} League Dues")

      if !payments.empty?
        true
      else
        false
      end
    end
  end

  # date parsing
  def starts_at=(date)
    parsed = EzglCalendar::CalendarUtils.datetime_for_picker_date("#{date} 12:01 AM")
    super parsed
  rescue
    write_attribute(:starts_at, date)
  end

  def ends_at=(date)
    parsed = EzglCalendar::CalendarUtils.datetime_for_picker_date("#{date} 11:59 PM")
    super parsed
  rescue
    write_attribute(:ends_at, date)
  end
end
