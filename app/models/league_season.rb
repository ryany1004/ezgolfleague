class LeagueSeason < ActiveRecord::Base
  belongs_to :league
  has_many :payments, inverse_of: :league_season

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

  def rankings_cache_key
    return "league-rankings#{self.id}-#{self.updated_at.to_s}"
  end

  #date parsing
  def starts_at=(date)
    begin
      parsed = DateTime.strptime("#{date} 12:01 AM #{Time.zone.now.formatted_offset}", JAVASCRIPT_DATETIME_PICKER_FORMAT) #does this need to be the offset of the actual time to match DST?!?
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
    payments = self.payments.where(user: user)

    if payments.length > 0
      return true
    else
      return false
    end
  end

end
