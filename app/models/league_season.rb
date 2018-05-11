class LeagueSeason < ApplicationRecord
  belongs_to :league, touch: true

  has_many :payments, inverse_of: :league_season
  has_many :subscription_credits, ->{ order 'created_at DESC' }
  has_many :league_season_scoring_groups, dependent: :destroy

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

      if !user_is_in_any_group
        users_not_in_groups << u
      end
    end

    users_not_in_groups
  end

  def rankings_cache_key
    return "league-rankings#{self.id}-#{self.updated_at.to_s}"
  end

  #date parsing
  def starts_at=(date)
    begin
      parsed = DateTime.strptime("#{date} 12:01 AM #{Time.zone.now.formatted_offset}", JAVASCRIPT_DATETIME_PICKER_FORMAT)
      super parsed
    rescue
      write_attribute(:starts_at, date)
    end
  end

  def ends_at=(date)
    begin
      parsed = DateTime.strptime("#{date} 11:59 PM #{Time.zone.now.formatted_offset}", JAVASCRIPT_DATETIME_PICKER_FORMAT)
      super parsed
    rescue
      write_attribute(:ends_at, date)
    end
  end

  def complete_name
    return "#{self.name} (#{self.league.name})"
  end

  def user_has_paid?(user)
    if self.dues_amount == 0
      return true
    else
      payments = self.payments.where(user: user).where("payment_amount > 0").where("payment_type = ?", "#{user.complete_name} League Dues")

      if payments.length > 0
        return true
      else
        return false
      end
    end
  end

end
