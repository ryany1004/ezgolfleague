class Tournament < ActiveRecord::Base
  belongs_to :league, inverse_of: :tournaments
  belongs_to :course, inverse_of: :tournaments
  has_many :tournament_groups, -> { order(:tee_time_at) }, inverse_of: :tournament, :dependent => :destroy
  has_and_belongs_to_many :course_holes, -> { order(:hole_number) }
  
  validates :name, presence: true
  validates :tournament_at, presence: true
  validates :signup_opens_at, presence: true
  
  paginates_per 50
  
  #date parsing
  def tournament_at=(date)
    begin
      parsed = Date.strptime(date,'%m/%d/%Y %I:%M %p')
      super parsed
    rescue
      date         
    end
  end
  
  def signup_opens_at=(date)
    begin
      parsed = Date.strptime(date,'%m/%d/%Y %I:%M %p')
      super parsed
    rescue
      date         
    end
  end
  
  def signup_closes_at=(date)
    begin
      parsed = Date.strptime(date,'%m/%d/%Y %I:%M %p')
      super parsed
    rescue
      date         
    end
  end
  
end