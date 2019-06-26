class User < ApplicationRecord
  include Servable

  include Users::NotificationSupport
  include Users::HandicapSupport

  acts_as_paranoid

  devise :invitable, :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  has_many :league_memberships, inverse_of: :user, dependent: :destroy
  has_many :leagues, ->{ order 'name' }, through: :league_memberships
  has_many :league_memberships_admin, -> { where is_admin: true }, class_name: 'LeagueMembership'
  has_many :leagues_admin, through: :league_memberships_admin, class_name: 'League', source: :league
  has_many :tournaments, through: :leagues, class_name: 'Tournament', source: :tournaments
  has_many :tournaments_admin, through: :leagues_admin, class_name: 'Tournament', source: :tournaments
  has_many :payout_results, inverse_of: :user, dependent: :destroy
  has_many :golf_outings, inverse_of: :user, dependent: :destroy
  has_many :payments, ->{ order 'created_at DESC' }, inverse_of: :user, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :mobile_devices, dependent: :destroy
  has_many :tournament_day_results, inverse_of: :user, dependent: :destroy
  has_many :scoring_rule_participations, inverse_of: :user
  has_many :scoring_rules, through: :scoring_rule_participations
  has_many :league_season_team_memberships, inverse_of: :user
  has_many :league_season_teams, through: :league_season_team_memberships
  has_many :league_season_rankings, dependent: :destroy
  belongs_to :current_league, class_name: "League", optional: true
  has_many :child_users, ->{ order 'last_name' }, class_name: "User", foreign_key: "parent_id", inverse_of: :parent_user
  belongs_to :parent_user, class_name: "User", foreign_key: "parent_id", inverse_of: :child_users, optional: true
  has_and_belongs_to_many :flights, inverse_of: :users
  has_and_belongs_to_many :daily_teams, inverse_of: :users
  has_and_belongs_to_many :league_season_scoring_groups, inverse_of: :users

  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :time_zone, presence: true

  attr_accessor :should_invite, :agreed_to_terms, :account_to_merge_to

  before_update :clear_current_league
  before_update :reset_session, if: :encrypted_password_changed?

  after_commit :send_to_drip

  accepts_nested_attributes_for :league_memberships

  paginates_per 50

  has_attached_file :avatar, styles: { medium: "300x300#", thumb: "100x100#" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  #this is to work around a Devise bug
  def after_password_reset; end

  def reset_session
    self.session_token = nil
  end

  def clear_current_league
    self.current_league = nil if !self.leagues.include?(self.current_league)
  end

  def complete_name
    "#{self.first_name} #{self.last_name}"
  end

  def complete_name_with_email
    complete_name + " (#{self.email})"
  end

  def scoring_group_name_for_league_season(league_season)
    if league_season.league.allow_scoring_groups
      league_season.league_season_scoring_groups.each do |group|
        if group.users.include? self
          return "(#{group.name})"
        end
      end
    else
      ""
    end
  end

  def short_name
    "#{self.first_name} #{self.last_name[0]}."
  end

  def ghin_url
    #"http://widgets.ghin.com/HandicapLookupResults.aspx?entry=1&ghinno=#{self.ghin_number}&css=default&dynamic=&small=0&mode=&tab=0"
    "http://162.245.224.193/Widgets/HandicapLookupResults.aspx?entry=1&ghinno=#{self.ghin_number}&css=default&dynamic=&small=0&mode=&tab=0"
  end

  def drip_tags
    tags = []

    tags << "Golfer"
    tags << "League Admin" if self.is_any_league_admin?
    tags << "Mobile User" if self.mobile_devices.count > 0
    tags << "iOS User" if self.has_ios_devices?
    tags << "Android User" if self.has_android_devices?
    tags << "Paid League Member" if self.has_any_paid_leagues?

  	has_team_leagues = false
  	has_individual_leagues = false
  	self.leagues_admin.each do |l|
  		has_team_leagues = true if l.league_type == "Team Play"
  		has_individual_leagues = true if l.league_type == "Individual Play"
  	end

  	tags << "Team League Admin" if has_team_leagues
  	tags << "Individual League Admin" if has_individual_leagues

    self.leagues.each do |l|
      tags << l.name
    end

    tags
  end

  def send_to_drip
  	SendUserToDripJob.perform_later(self) if Rails.env.production?
  end

  def delete_from_drip
    response = DRIP_CLIENT.unsubscribe(self.email) if Rails.env.production?
  end

  def can_create_tournaments?
  	if self.is_super_user?
  		return true
  	else
  		if self.selected_league.present?
  			if self.selected_league.has_active_subscription?
  				return true
  			elsif self.selected_league.free_tournaments_remaining > 0
  				return true
  			end
  		else
  			return false
  		end
  	end

  	false
  end

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
      []
    else
      users = []

      users << self.parent_user unless self.parent_user.blank?
      users = users + self.child_users

      users
    end
  end

  def avatar_image_url
    self.avatar.url(:thumb)
  end

  def requires_additional_profile_data?
    if self.phone_number.blank? and self.street_address_1.blank?
      true
    else
      false
    end
  end

  def selected_league
  	if self.current_league.present? && self.leagues.include?(self.current_league)
  		self.current_league
  	else
  		if self.leagues_admin.first.present?
  			self.leagues_admin.first
  		else
  			self.leagues.first
  		end
  	end
  end

  def active_league_season
    self.selected_league.active_season_for_user(self)
  end

  def is_any_league_admin?
    return true if self.is_super_user
    return false if self.blank?

    self.leagues_admin.count > 0
  end

  def has_any_paid_leagues?
    self.leagues.each do |l|
      return true if l.has_active_subscription?
    end

    false
  end

  def has_all_exempt_leagues?
    all_exempt_leagues = true

    self.leagues.each do |league|
      all_exempt_leagues = false if !league.exempt_from_subscription
    end

    all_exempt_leagues
  end

  def is_member_of_league?(league)
  	self.league_memberships.where(league: league).present?
  end

  def league_membership_for_league(league)
    self.league_memberships.where(league: league).first
  end

  def payments_for_current_league
    self.payments_for_league(self.selected_league)
  end

  def payments_cache_key
    max_updated_at = self.payments.maximum(:updated_at).try(:utc).try(:to_s, :number)
    cache_key = "payments/#{self.id}-#{max_updated_at}"
  end

  def payments_for_league(league)
    cache_key = self.payments_cache_key
    total_payments = 0.0

    total_payments = Rails.cache.fetch(cache_key, expires_in: 24.hours, race_condition_ttl: 10) do
      league_season_ids = []
      league.league_seasons.each do |l|
        league_season_ids << l.id
      end

      scoring_rule_payments = []
      unless league_season_ids.blank?
        league_payments = self.payments.where("league_season_id IN (?)", league_season_ids)

        self.payments.each do |p|
          scoring_rule_payments << p if league_season_ids.include? p.scoring_rule&.tournament_day&.tournament&.league&.league_seasons&.pluck(:id)
        end
      end

      return league_payments + scoring_rule_payments
    end

    total_payments
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

  def league_names_string
    league_names = self.leagues.map {|n| n.name}

    return league_names.join(", ")
  end
end
