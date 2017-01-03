class NotificationTemplate < ActiveRecord::Base
  belongs_to :league
  belongs_to :tournament

  has_many :notifications

  validates :title, presence: true
  validates :body, presence: true
  validates :deliver_at, presence: true
  validate :recipients_are_valid

  paginates_per 50

  before_save :set_deliver_date_for_action
  before_save :block_future_notifications

  def set_deliver_date_for_action
    if self.tournament_notification_action == "To Unregistered Members 1 Day Before Registration Closes"
      self.deliver_at = self.tournament.signup_closes_at - 1.day
    end
  end

  def block_future_notifications
    if self.tournament_notification_action == "On Finalization"
      self.has_been_delivered = true
    end
  end

  def recipients_are_valid
    if league.blank? && tournament.blank?
      errors.add(:league_id, "can't both be blank")
      errors.add(:tournament_id, "can't both be blank")
    end
  end

  def recipients
    if self.tournament_notification_action.blank?
      if self.tournament.blank?
        return self.league.users
      else
        return self.tournament.players
      end
    else
      if self.tournament_notification_action == "On Finalization"
        return self.tournament.players
      elsif self.tournament_notification_action == "To Unregistered Members 1 Day Before Registration Closes"
        unregistered = []

        self.league.users.each do |u|
          unregistered << u if self.tournament.includes_player?(u) == false
        end

        return unregistered
      end
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
