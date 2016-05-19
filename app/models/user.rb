class User < ActiveRecord::Base
  include Handicapable
  include Servable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :registerable
  devise :invitable, :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  has_many :league_memberships, :dependent => :destroy
  has_many :leagues, through: :league_memberships
  has_many :payout_results, inverse_of: :user, :dependent => :destroy
  has_many :payments, ->{ order 'created_at DESC' }, inverse_of: :user
  has_many :tournament_day_results, inverse_of: :tournament_day, :dependent => :destroy
  has_many :notifications, :dependent => :destroy
  has_many :mobile_devices, :dependent => :destroy
  belongs_to :current_league, :class_name => "League"
  has_and_belongs_to_many :flights, inverse_of: :users
  has_and_belongs_to_many :golfer_teams, inverse_of: :users
  has_and_belongs_to_many :contests, inverse_of: :users

  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  attr_accessor :should_invite

  paginates_per 50

  #this is to work around a Devise bug
  def after_password_reset; end

  def complete_name(shorten_for_print = false)
    if shorten_for_print == true
      combined_name = "#{self.last_name}, #{self.first_name}"
      shortened_name = ActionController::Base.helpers.truncate(combined_name, length: 25)

      return shortened_name
    else
      return "#{self.last_name}, #{self.first_name}"
    end
  end

  def short_name
    return "#{self.first_name}, #{self.last_name[0]}"
  end

  ##

  def current_watch_complication_score
    payload = {}

    Tournament.all_today(self.leagues).each do |t|
      t.tournament_days.each do |td|
        if td.tournament_day_results.count > 0
          your_results = td.tournament_day_results.where(user: self).first
          winner_result = td.tournament_day_results.first

          payload = {:tournament_id => t.server_id, :tournament_day_id => td.server_id, :your_score => {:score => your_results.net_score, :name => ""}, :top_score => {:score => winner_result.net_score, :name => winner_result.user.short_name}}
        end
      end
    end

    return payload
  end

  ##

  def requires_additional_profile_data?
    if self.phone_number.blank? and self.street_address_1.blank?
      return true
    else
      return false
    end
  end

  def selected_league
    unless self.current_league.blank?
      return self.current_league
    else
      return self.leagues.first
    end
  end

  def is_any_league_admin?
    return true if self.is_super_user
    return false if self.blank?

    self.leagues.each do |league|
      membership = league.membership_for_user(self)

      unless membership.blank?
        return membership.is_admin
      else
        return false
      end
    end

    return false
  end

  def is_member_of_league?(league)
    if self.league_memberships.where("league_id = ?", league.id).blank?
      return false
    else
      return true
    end
  end

  def payments_for_current_league
    return self.payments_for_league(self.selected_league)
  end

  def payments_for_league(league)
    league_season_ids = []
    league.league_seasons.each do |l|
      league_season_ids << l.id
    end

    tournament_payments = []
    unless league_season_ids.blank?
      league_payments = self.payments.where("league_season_id IN (?)", league_season_ids)
      tournament_payments = self.payments.joins(:tournament).where(tournaments: {league_id: league.id})
    end

    contest_ids = []
    self.selected_league.tournaments.each do |t|
      t.tournament_days.each do |d|
        d.contests.each do |c|
          contest_ids << c
        end
      end
    end

    unless contest_ids.blank?
      contest_payments = self.payments.where("contest_id IN (?)", contest_ids)

      return league_payments + tournament_payments + contest_payments
    else
      return league_payments + tournament_payments
    end
  end

  # def send_mobile_notification(body, pusher = nil)
  #   return if self.wants_push_notifications == false
  #
  #   pusher = User.pusher if pusher.blank?
  #
  #   self.mobile_devices.where(device_type: "iphone").each do |device|
  #     pusher = User.pusher(true) if device.environment_name == "debug"
  #
  #     notification = Grocer::Notification.new(
  #       device_token: device.device_identifier,
  #       alert: body
  #     )
  #
  #     Rails.logger.info { "Pushing Standard Notification to #{device.device_identifier} #{device.environment_name}" }
  #
  #     pusher.push(notification)
  #   end
  # end
  #
  # def send_complication_notification(content)
  #   return if self.wants_push_notifications == false
  #
  #   pusher = User.pusher if pusher.blank?
  #
  #   self.mobile_devices.where(device_type: "apple-watch-complication").each do |device|
  #     pusher = User.pusher(true) if device.environment_name == "debug"
  #
  #     notification = Grocer::Notification.new(
  #       device_token: device.device_identifier,
  #       content_available: true,
  #       custom: content
  #     )
  #
  #     Rails.logger.info { "Pushing Complication Notification to #{device.device_identifier} #{device.environment_name}" }
  #
  #     pusher.push(notification)
  #   end
  # end
  #
  # def self.pusher(use_debug = false)
  #   if use_debug == true
  #     pusher = Grocer.pusher(
  #       certificate: "#{Rails.root}/config/apns_cert.pem",
  #       passphrase:  "golf",
  #       gateway:     "gateway.sandbox.push.apple.com"
  #     )
  #   else
  #     pusher = Grocer.pusher(
  #       certificate: "#{Rails.root}/config/apns_cert.pem",
  #       passphrase:  "golf",
  #       gateway:     "gateway.push.apple.com"
  #     )
  #   end
  # end

  def send_mobile_notification(body, pusher = nil)
    return if self.wants_push_notifications == false

    pusher = User.pusher if pusher.blank?

    self.mobile_devices.where(device_type: "iphone").each do |device|
      pusher = User.pusher(true) if device.environment_name == "debug"

      notification = Apnotic::Notification.new(device.device_identifier)
      notification.alert = body
      notification.priority = 10

      Rails.logger.info { "Pushing Standard Notification to #{device.device_identifier} #{device.environment_name}" }

      response = pusher.push(notification)

      Rails.logger.info { "Notification Response: #{response}" }
    end

    pusher.close
  end

  def send_complication_notification(content)
    return if self.wants_push_notifications == false

    self.mobile_devices.where(device_type: "apple-watch-complication").each do |device|
      certificate_file = "#{Rails.root}/config/apns_complication_cert.pem"
      passphrase = "golf"

      if device.environment_name == "debug"
        pusher = Apnotic::Connection.development(cert_path: certificate_file, cert_pass: passphrase)
      else
        pusher = Apnotic::Connection.new(cert_path: certificate_file, cert_pass: passphrase)
      end

      notification = Apnotic::Notification.new(device.device_identifier)
      notification.content_available = 1
      notification.custom_payload = content

      Rails.logger.info { "Pushing Complication Notification to #{device.device_identifier} #{device.environment_name}" }

      response = pusher.push(notification)

      Rails.logger.info { "Notification Response: #{response}" }

      pusher.close
    end
  end

  def self.pusher(use_debug = false)
    certificate_file = "#{Rails.root}/config/apns_cert.pem"
    passphrase = "golf"

    if use_debug == true
      connection = Apnotic::Connection.development(cert_path: certificate_file, cert_pass: passphrase)
    else
      connection = Apnotic::Connection.new(cert_path: certificate_file, cert_pass: passphrase)
    end

    return connection
  end

  ##Custom Devise

  def league_names_string
    league_names = self.leagues.map {|n| n.name}

    return league_names.join(", ")
  end

  def invite_email_subject
    unless self.leagues.count == 0
      return self.league_names_string + " - You Have Been Invited!"
    else
      return "EZ Golf League - You Have Been Invited!"
    end
  end

end
