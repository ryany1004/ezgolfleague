class Tournament < ActiveRecord::Base
  include Findable
  include Playable
  
  belongs_to :league, inverse_of: :tournaments
  has_many :tournament_days, -> { order(:tournament_at) }, inverse_of: :tournament, :dependent => :destroy
  has_many :payments, inverse_of: :tournament

  attr_accessor :another_member_id
  attr_accessor :number_of_days_to_create
  attr_accessor :skip_date_validation
  
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
  
    if signup_opens_at.present? && self.first_day.tournament_at.present? && self.first_day.tournament_at < signup_opens_at
      errors.add(:signup_opens_at, "can't be after the tournament")
    end
  
    if signup_opens_at.present? && signup_closes_at.present? && signup_opens_at > signup_closes_at
      errors.add(:signup_closes_at, "can't be before the sign up opening")
    end
  end
  
  paginates_per 50

  def first_day
    return self.tournament_days.first
  end
  
  def last_day
    return self.tournament_days.last
  end

  def courses
    distinct_courses = []
    
    self.tournament_days.each do |day|
      distinct_courses << day.course unless distinct_courses.include? day.course
    end
    
    return distinct_courses
  end

  ##

  def is_past?
    if self.last_day.tournament_at > DateTime.yesterday
      return false
    else
      return true
    end
  end
  
  def is_open_for_registration?
    return false if self.number_of_players >= self.max_players
    return false if self.signup_opens_at > Time.zone.now
    
    days_without_flights = false
    self.tournament_days.each do |day|
      days_without_flights = true if day.flights.count == 0
    end
    return false if days_without_flights == true
  
    return true
  end
  
  ##
  
  def update_course_handicaps
    self.tournament_days.each do |day|
      day.tournament_groups.each do |group|
        group.teams.each do |team|
          team.golf_outings.each do |outing|
            outing.scorecards.each do |card|
              card.set_course_handicap(true)
            end
          end
        end
      end
    end
  end
  
  ##
  
  def user_has_paid?(user)
    tournament_balance = 0.0
    
    self.payments.where(user: user).each do |p|
      tournament_balance = tournament_balance + p.payment_amount
    end
    
    if tournament_balance == 0.0
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
  
end