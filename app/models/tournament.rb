class Tournament < ActiveRecord::Base
  include Playable
  include Addable
  include Scoreable
  include Rankable
  
  belongs_to :league, inverse_of: :tournaments
  belongs_to :course, inverse_of: :tournaments
  belongs_to :mens_tee_box, :class_name => "CourseTeeBox", :foreign_key => "mens_tee_box_id"
  belongs_to :womens_tee_box, :class_name => "CourseTeeBox", :foreign_key => "womens_tee_box_id"
  has_many :tournament_groups, -> { order(:tee_time_at) }, inverse_of: :tournament, :dependent => :destroy
  has_many :flights, -> { order(:flight_number) }, inverse_of: :tournament, :dependent => :destroy
  has_and_belongs_to_many :course_holes, -> { order(:hole_number) }
  
  validates :name, presence: true
  validates :tournament_at, presence: true
  validates :signup_opens_at, presence: true
  
  paginates_per 50
  
  def is_past?
    if self.tournament_at > DateTime.yesterday
      return false
    else
      return true
    end
  end
  
  #date parsing
  def tournament_at=(date)
    begin
      parsed = DateTime.strptime("#{date} #{Time.zone.now.formatted_offset}", JAVASCRIPT_DATETIME_PICKER_FORMAT)
      super parsed
    rescue
      write_attribute(:tournament_at, date)
    end
  end
  
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