class League < ApplicationRecord
  include Servable

  has_many :league_seasons, -> { order 'starts_at' }, dependent: :destroy, inverse_of: :league
  has_many :league_memberships, -> { includes(:user).order('users.last_name') }, dependent: :destroy
  has_many :users, -> { order 'last_name, first_name' }, through: :league_memberships
  has_many :tournaments, dependent: :destroy, inverse_of: :league
  has_many :notification_templates, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :free_tournaments_remaining, presence: true
  validates :number_of_rounds_to_handicap, presence: true
  validates :number_of_lowest_rounds_to_handicap, presence: true

  validate :handicap_rounds_bounds_are_correct, on: :create
  def handicap_rounds_bounds_are_correct
    if number_of_lowest_rounds_to_handicap > number_of_rounds_to_handicap
      errors.add(:number_of_lowest_rounds_to_handicap, 'cannot be more than the total number of rounds')
    end
  end

  paginates_per 50

  after_create :create_default_league_season
  after_create :notify_super_users

  attr_encrypted :stripe_test_secret_key, key: ENCRYPYTED_ATTRIBUTES_KEY, algorithm: 'aes-256-cbc', mode: :single_iv_and_salt, insecure_mode: true
  attr_encrypted :stripe_production_secret_key, key: ENCRYPYTED_ATTRIBUTES_KEY, algorithm: 'aes-256-cbc', mode: :single_iv_and_salt, insecure_mode: true
  attr_encrypted :stripe_test_publishable_key, key: ENCRYPYTED_ATTRIBUTES_KEY, algorithm: 'aes-256-cbc', mode: :single_iv_and_salt, insecure_mode: true
  attr_encrypted :stripe_production_publishable_key, key: ENCRYPYTED_ATTRIBUTES_KEY, algorithm: 'aes-256-cbc', mode: :single_iv_and_salt, insecure_mode: true

  def self.clean_for_dev
    League.all.find_each do |l|
      l.location = 'x' if l.location.blank?
      l.encrypted_stripe_test_secret_key = nil
      l.encrypted_stripe_production_secret_key = nil
      l.encrypted_stripe_test_publishable_key = nil
      l.encrypted_stripe_production_publishable_key = nil
      l.stripe_token = nil

      l.save!
    end
  end

  def stripe_publishable_key
    if Rails.env.staging? || stripe_test_mode
      stripe_test_publishable_key
    else
      stripe_production_publishable_key
    end
  end

  def stripe_secret_key
    if Rails.env.staging? || stripe_test_mode
      stripe_test_secret_key
    else
      stripe_production_secret_key
    end
  end

  def stripe_is_setup?
    return false if Rails.env.development?

    if stripe_test_publishable_key.blank? || stripe_production_publishable_key.blank?
      false
    else
      true
    end
  end

  def user_is_admin(user)
    membership = league_memberships.where(user: user).first
    if membership.blank? || !membership.is_admin
      false
    else
      true
    end
  end

  def league_admins
    users = []

    admin_memberships = league_memberships.where(is_admin: true)
    admin_memberships.each do |m|
      users << m.user
    end

    users
  end

  def notify_super_users
    title = "New League Created: #{name}"

    body = "A new league has been created.\n\n"
    body += name + "\n\n"
    body += "Season Starts: #{start_date}\n\n"
    body += "League Type: #{league_type}\n\n"
    body += "Estimated Players: #{league_estimated_players}\n\n"
    body += "Comments: #{more_comments}\n\n"
    body += "https://app.ezgolfleague.com/leagues/#{id}/edit"

    User.where(is_super_user: true).each do |u|
      NotificationMailer.notification_message(u, 'support@ezgolfleague.com', title, body).deliver_later
    end
  end

  def create_default_league_season
    create_season_for_year(Time.zone.now.year) if active_season.blank?
  end

  def create_season_for_year(year)
    start_date = Date.civil(year, 1, 1)
    end_date = Date.civil(year, -1, -1)

    last_season = league_seasons.last

    s = LeagueSeason.create(name: Time.zone.now.year.to_s, starts_at: start_date, ends_at: end_date, league: self)
    s.update(season_type_raw: LeagueSeasonType::TEAM) if league_type == 'Team Play'
    s.update(dues_amount: last_season.dues_amount) if last_season.present?
  end

  def create_missing_next_season
    last_season = league_seasons.last
    current_season = active_season

    return if current_season.blank?

    if current_season.ends_at - 60.days < DateTime.now && current_season == last_season
      new_year = Time.zone.now.beginning_of_year + 1.year

      create_season_for_year(new_year)
    end
  end

  def membership_for_user(user)
    league_memberships.where(user: user).first
  end

  def set_user_as_active(user)
    membership = membership_for_user(user)
    membership.state == MembershipStates::ACTIVE_FOR_BILLING
    membership.save
  end

  def dues_for_user(user, include_credit_card_fees = true)
    membership = league_memberships.where(user: user).first

    unless membership.blank?
      dues_amount = dues_amount
      discount_amount = dues_amount - membership.league_dues_discount
      credit_card_fees = 0.0

      credit_card_fees = Stripe::StripeFees.fees_for_transaction_amount(discount_amount) if include_credit_card_fees == true

      total = discount_amount + credit_card_fees

      total
    else
      0
    end
  end

  def cost_breakdown_for_user(user)
    membership = league_memberships.where(user: user).first

    cost_lines = [
      { name: "#{name} League Fees", price: dues_amount },
      { name: "Dues Discount", price: (membership.league_dues_discount * -1.0) },
      { name: "Credit Card Fees", price: Stripe::StripeFees.fees_for_transaction_amount(dues_amount - membership.league_dues_discount) }
    ]

    cost_lines
  end

  def dues_amount
    season = active_season

    unless season.blank?
      season.dues_amount.to_f
    else
      0.0
    end
  end

  def has_active_subscription?
    return true if exempt_from_subscription
    return false if active_season.blank?

    active_subscriptions = active_season.subscription_credits
    if active_subscriptions.count.positive?
      true
    else
      false
    end
  end

  def has_ever_subscribed?
    league_seasons.each do |s|
      return true if s.subscription_credits.count.positive?
    end

    false
  end

  def active_season
    this_year_season = league_seasons.where("starts_at <= ? AND ends_at >= ?", Date.current.in_time_zone, Date.current.in_time_zone).first

    this_year_season
  end

  def active_season_for_user(user)
    this_year_season = user.selected_league.league_seasons.where("starts_at < ? AND ends_at > ?", Date.current.in_time_zone, Date.current.in_time_zone).first

    if this_year_season.present?
      this_year_season
    else
      user.selected_league.league_seasons.last
    end
  end

  def golfer_count
    users.count
  end

  def active_golfer_count
    league_memberships.active.count
  end

  def state_for_user(user)
    membership = membership_for_user(user)
    membership.state
  end

  def users_not_signed_up_for_tournament(tournament, tournament_day, extra_ids_to_omit)
    if tournament_day.blank?
      tournament_users = tournament.players
    else
      tournament_users = tournament.players_for_day(tournament_day)
    end

    ids_to_omit = tournament_users.map { |n| n.id }

    extra_ids_to_omit.each do |eid|
      ids_to_omit << eid
    end

    if ids_to_omit.blank?
      users.order("last_name, first_name")
    else
      users.where("users.id NOT IN (?)", ids_to_omit).order("last_name, first_name")
    end
  end

  def self.to_csv
    attributes = %w{name contact_email league_type golfer_count active_golfer_count created_at}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |user|
        csv << attributes.map { |attr| user.send(attr) }
      end
    end
  end

  # date parsing
  def start_date=(date)
    begin
      parsed = EzglCalendar::CalendarUtils.date_for_picker_date(date)
      super parsed
    rescue
      write_attribute(:start_date, date)
    end
  end
end
