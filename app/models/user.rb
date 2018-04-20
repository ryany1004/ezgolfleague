class User < ApplicationRecord
  include Handicapable
  include Servable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :registerable
  devise :invitable, :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  has_many :league_memberships, :dependent => :destroy
  has_many :leagues, ->{ order 'name' }, through: :league_memberships
  has_many :league_memberships_admin, -> { where is_admin: true }, class_name: 'LeagueMembership'
  has_many :leagues_admin, :through => :league_memberships_admin, class_name: 'League', :source => :league
  has_many :tournaments, :through => :leagues, class_name: 'Tournament', :source => :tournaments
  has_many :tournaments_admin, :through => :leagues_admin, class_name: 'Tournament', :source => :tournaments
  has_many :payout_results, inverse_of: :user, :dependent => :destroy
  has_many :golf_outings, inverse_of: :user, :dependent => :destroy
  has_many :payments, ->{ order 'created_at DESC' }, inverse_of: :user, :dependent => :destroy
  has_many :tournament_day_results, inverse_of: :tournament_day, :dependent => :destroy
  has_many :notifications, :dependent => :destroy
  has_many :mobile_devices, :dependent => :destroy
  belongs_to :current_league, :class_name => "League"
  has_many :child_users, ->{ order 'last_name' }, class_name: "User", foreign_key: "parent_id", inverse_of: :parent_user
  belongs_to :parent_user, class_name: "User", foreign_key: "parent_id", inverse_of: :child_users
  has_and_belongs_to_many :flights, inverse_of: :users
  has_and_belongs_to_many :golfer_teams, inverse_of: :users
  has_and_belongs_to_many :contests, inverse_of: :users

  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  attr_accessor :should_invite, :agreed_to_terms, :account_to_merge_to

  before_update :reset_session, if: :encrypted_password_changed?

  paginates_per 50

  has_attached_file :avatar, :styles => { :medium => "300x300#", :thumb => "100x100#" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  #this is to work around a Devise bug
  def after_password_reset; end

  def reset_session
    self.session_token = nil
  end

  def complete_name
    return "#{self.first_name} #{self.last_name}"
  end

  def complete_name_with_email
    return complete_name + " (#{self.email})"
  end

  def short_name
    return "#{self.first_name} #{self.last_name[0]}."
  end

  def ghin_url
    #"http://widgets.ghin.com/HandicapLookupResults.aspx?entry=1&ghinno=#{self.ghin_number}&css=default&dynamic=&small=0&mode=&tab=0"
    "http://162.245.224.193/Widgets/HandicapLookupResults.aspx?entry=1&ghinno=#{self.ghin_number}&css=default&dynamic=&small=0&mode=&tab=0"
  end

  ##

  def can_edit_user?(user)
    return true if self.is_super_user
    return false if self.blank?

    is_admin_of_league = false

    self.leagues_admin.each do |l|
      is_admin_of_league = true if l.users.include?(user)
    end

    is_admin_of_league
  end

  def impersonatable_users
    if self.child_users.blank? && self.parent_user.blank?
      return []
    else
      users = []

      users << self.parent_user unless self.parent_user.blank?
      users = users + self.child_users

      users
    end
  end

  def merge_into_user(user, should_delete = false)
    User.transaction do
      self.league_memberships.each do |l|
        user.league_memberships << l
      end
      self.league_memberships.clear

      self.golf_outings.each do |g|
        user.golf_outings << g
      end

      self.payout_results.each do |p|
        user.payout_results << p
      end

      self.payments.each do |p|
        user.payments << p
      end

      self.tournament_day_results.each do |t|
        user.tournament_day_results << t
      end

      self.child_users.each do |u|
        user.child_users << u
      end
      self.child_users.clear

      user.parent_user = self.parent_user
      self.parent_user = nil

      self.flights.each do |f|
        user.flights << f
      end
      self.flights.clear

      self.golfer_teams.each do |g|
        user.golfer_teams << g
      end
      self.golfer_teams.clear

      self.contests.each do |c|
        user.contests << c
      end
      self.contests.clear

      user.save

      self.save
      self.destroy if should_delete
    end
  end

  def avatar_image_url
    return self.avatar.url(:thumb)
  end

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
      unless self.leagues_admin.first.blank?
        return self.leagues_admin.first
      else
        return self.leagues.first
      end
    end
  end

  def active_league_season
    self.selected_league.active_season_for_user(self)
  end

  def is_any_league_admin?
    return true if self.is_super_user
    return false if self.blank?

    return self.leagues_admin.count > 0
  end

  def has_all_exempt_leagues?
    all_exempt_leagues = true

    self.leagues.each do |league|
      all_exempt_leagues = false if !league.exempt_from_subscription
    end

    all_exempt_leagues
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

  def names_of_leagues_admin
    names = ""

    self.leagues_admin.each do |l|
      names += l.name + " "
    end

    names
  end

  def self.to_csv
    attributes = %w{id email first_name last_name phone_number names_of_leagues_admin created_at}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
  end

  ## Notifications

  def ios_devices
    self.mobile_devices.where(device_type: "iphone")
  end

  def apple_watch_devices
    self.mobile_devices.where(device_type: "apple-watch-complication")
  end

  def android_devices
    self.mobile_devices.where(device_type: "android")
  end

  def has_ios_devices?
    self.ios_devices.count >= 1
  end

  def has_apple_watch_devices?
    self.apple_watch_devices.count >= 1
  end

  def has_android_devices?
    self.android_devices.count >= 1
  end

  def send_mobile_notification(body, extra_data = nil)
    return if self.wants_push_notifications == false

    push_notifier = Notifications::PushNotification.new
    push_notifier.send_notification(self, body, extra_data)
  end

  def send_silent_notification(extra_data = nil)
    return if !self.has_ios_devices?

    push_notifier = Notifications::IosPushNotification.new
    push_notifier.send_silent_notification(self, extra_data)
  end

  def send_complication_notification(content)
    return if !self.has_apple_watch_devices?

    push_notifier = Notifications::IosPushNotification.new
    push_notifier.send_complication_notification(self, content)
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
