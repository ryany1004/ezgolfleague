module AutoScheduleType
  MANUAL = 0
  AUTOMATIC_WORST_FIRST = 1
  AUTOMATIC_BEST_FIRST = 2
end

class Tournament < ActiveRecord::Base
  include Findable
  include Playable
  include Rankable
  include Servable

  belongs_to :league, inverse_of: :tournaments
  has_many :tournament_days, -> { order(:tournament_at) }, inverse_of: :tournament, :dependent => :destroy
  has_many :payments, inverse_of: :tournament

  accepts_nested_attributes_for :tournament_days

  attr_accessor :another_member_id
  attr_accessor :skip_date_validation
  attr_accessor :contests_to_enter

  validates :name, presence: true
  validates :signup_opens_at, presence: true
  validates :signup_closes_at, presence: true
  validates :max_players, presence: true

  validate :dates_are_valid, on: :create, unless: "self.skip_date_validation == true"
  def dates_are_valid
    now = Time.zone.now.at_beginning_of_day

    if signup_opens_at.present? && signup_opens_at < now
      errors.add(:signup_opens_at, "can't be in the past")
    end

    if signup_closes_at.present? && signup_closes_at < now
      errors.add(:signup_closes_at, "can't be in the past")
    end

    unless self.first_day.blank?
      if signup_opens_at.present? && self.first_day.tournament_at.present? && self.first_day.tournament_at < signup_opens_at
        errors.add(:signup_opens_at, "can't be after the tournament")
      end
    end

    if signup_opens_at.present? && signup_closes_at.present? && signup_opens_at > signup_closes_at
      errors.add(:signup_closes_at, "can't be before the sign up opening")
    end
  end

  paginates_per 50

  def league_season
    return nil if self.first_day.blank?

    self.league.league_seasons.each do |s|
      if self.first_day.tournament_at >= s.starts_at && self.first_day.tournament_at < s.ends_at
        return s
      end
    end

    return nil
  end

  def season_name
    season = self.league_season

    unless season.blank?
      return season.name
    else
      return "?"
    end
  end

  def first_day
    return self.tournament_days.first
  end

  def last_day
    return self.tournament_days.last
  end

  def previous_day_for_day(day)
    index_for_day = self.tournament_days.index(day)
    unless index_for_day.blank?
      if self.tournament_days.count >= (index_for_day - 1)
        self.tournament_days[index_for_day - 1]
      else
        return nil
      end
    else
      return nil
    end
  end

  ##

  def dues_for_user(user, include_credit_card_fees = false)
    membership = user.league_memberships.where("league_id = ?", self.league.id).first

    unless membership.blank?
      dues_amount = self.dues_amount

      credit_card_fees = 0
      credit_card_fees = Stripe::StripeFees.fees_for_transaction_amount(dues_amount) if include_credit_card_fees == true

      return (dues_amount + credit_card_fees).round(2)
    else
      return 0
    end
  end

  def cost_breakdown_for_user(user, include_credit_card_fees = true)
    membership = user.league_memberships.where("league_id = ?", self.league.id).first

    cost_lines = [
      {:name => "#{self.name} Fees", :price => self.dues_amount, :server_id => self.id.to_s}
    ]

    if include_credit_card_fees == true
      cost_lines << {:name => "Credit Card Fees", :price => Stripe::StripeFees.fees_for_transaction_amount(self.dues_amount)}
    end

    return cost_lines
  end

  ##

  def courses
    distinct_courses = []

    self.tournament_days.each do |day|
      distinct_courses << day.course unless distinct_courses.include? day.course
    end

    return distinct_courses
  end

  def paid_contests
    contests = []

    self.tournament_days.each do |td|
      td.contests.each do |c|
        contests << c if c.dues_amount > 0
      end
    end

    return contests
  end

  ##

  def can_be_finalized?
    return self.last_day.can_be_finalized?
  end

  ##

  def is_past?
    return false if self.first_day.blank?

    if self.last_day.tournament_at > DateTime.yesterday
      return false
    else
      return true
    end
  end

  def is_open_for_registration?
    return false if self.number_of_players >= self.max_players
    return false if self.signup_opens_at > Time.zone.now
    return false if self.signup_closes_at < Time.zone.now

    unplayable_days = false
    self.tournament_days.each do |day|
      unplayable_days = true if day.can_be_played? == false
    end
    return false if unplayable_days == true

    return true
  end

  ##

  def update_course_handicaps
    self.tournament_days.each do |day|
      day.tournament_groups.each do |group|
        group.golf_outings.each do |outing|
          outing.scorecard.set_course_handicap(true)
        end
      end
    end
  end

  ##

  def user_has_paid?(user)
    tournament_balance = 0.0

    self.payments.where(user: user).each do |p|
      tournament_balance = tournament_balance + p.payment_amount if p.payment_amount > 0 #add the payments
    end

    if tournament_balance > 0 && tournament_balance >= self.dues_for_user(user)
      return true
    else
      return false
    end
  end

  #date parsing
  def signup_opens_at=(date)
    begin
      parsed = DateTime.strptime("#{date} #{Time.zone.now.formatted_offset}", JAVASCRIPT_DATETIME_PICKER_FORMAT)
      super parsed
    rescue
      write_attribute(:signup_opens_at, date)
    end
  end

  def signup_closes_at=(date)
    begin
      parsed = DateTime.strptime("#{date} #{Time.zone.now.formatted_offset}", JAVASCRIPT_DATETIME_PICKER_FORMAT)
      super parsed
    rescue
      write_attribute(:signup_closes_at, date)
    end
  end

  #JSON

  def as_json(options={})
    super(
      :only => :name,
      :methods => [:server_id, :number_of_players, :is_open_for_registration?, :dues_amount, :allow_credit_card_payment],
      :include => {
        :league => {
          :only => [:name, :apple_pay_merchant_id, :supports_apple_pay],
          :methods => [:server_id, :stripe_publishable_key]
        },
        :tournament_days => {
          :only => [:tournament_at],
          :methods => [:server_id, :can_be_played?, :registered_user_ids, :paid_user_ids],
          :include => {
            :course => {
              :only => [:name, :city, :us_state],
              :methods => [:server_id]
            }
          }
        }
      }
    )
  end

end
