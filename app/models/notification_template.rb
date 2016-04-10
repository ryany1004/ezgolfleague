class NotificationTemplate < ActiveRecord::Base
  belongs_to :league
  belongs_to :tournament

  has_many :notifications

  validates :title, presence: true
  validates :body, presence: true
  validates :deliver_at, presence: true
  validate :recipients_are_valid

  paginates_per 50

  def recipients_are_valid
    if league.blank? && tournament.blank?
      errors.add(:league_id, "can't both be blank")
      errors.add(:tournament_id, "can't both be blank")
    end
  end

  def recipients
    if self.tournament.blank?
      return self.league.users
    else
      return self.tournament.players
    end
  end

  def recipient_text
    if self.tournament.blank?
      return self.league.name
    else
      return self.tournament.name
    end
  end

  #date parsing
  def deliver_at=(date)
    begin
      parsed = DateTime.strptime("#{date} #{Time.zone.now.formatted_offset}", JAVASCRIPT_DATETIME_PICKER_FORMAT)
      super parsed
    rescue
      write_attribute(:deliver_at, date)
    end
  end

end
