class Tournament < ActiveRecord::Base
  include Playable
  include Addable
  include Scoreable
  
  belongs_to :league, inverse_of: :tournaments
  belongs_to :course, inverse_of: :tournaments
  has_many :tournament_groups, -> { order(:tee_time_at) }, inverse_of: :tournament, :dependent => :destroy
  has_many :flights, -> { order(:flight_number) }, inverse_of: :tournament, :dependent => :destroy
  has_many :contests, inverse_of: :tournament, :dependent => :destroy
  has_many :golfer_teams, inverse_of: :tournament, :dependent => :destroy
  has_and_belongs_to_many :course_holes, -> { order(:hole_number) }
    
  attr_accessor :another_member_id
  attr_accessor :skip_date_validation
  
  delegate :player_score, :player_points, :flights_with_rankings, :related_scorecards_for_user, :assign_payouts_from_scores, to: :game_type
  delegate :allow_teams, :show_teams?, :players_create_teams?, :show_team_scores_for_all_teammates?, to: :game_type
  delegate :other_group_members, :user_is_in_group?, to: :game_type
  delegate :handicap_allowance, to: :game_type
  delegate :can_be_played?, :can_be_finalized?, to: :game_type
  
  validates :name, presence: true
  validates :tournament_at, presence: true
  validates :signup_opens_at, presence: true
  validates :signup_closes_at, presence: true
  validates :max_players, presence: true
  
  validate :dates_are_valid, on: :create, unless: "self.skip_date_validation == true"
  def dates_are_valid
    now = Time.zone.now.at_beginning_of_day
  
    if tournament_at.present? && tournament_at < now
      errors.add(:tournament_at, "can't be in the past")
    end
  
    if signup_opens_at.present? && signup_opens_at < now
      errors.add(:signup_opens_at, "can't be in the past")
    end
  
    if signup_closes_at.present? && signup_closes_at < now
      errors.add(:signup_closes_at, "can't be in the past")
    end
  
    if signup_opens_at.present? && tournament_at.present? && tournament_at < signup_opens_at
      errors.add(:signup_opens_at, "can't be after the tournament")
    end
  
    if signup_opens_at.present? && signup_closes_at.present? && signup_opens_at > signup_closes_at
      errors.add(:signup_closes_at, "can't be before the sign up opening")
    end
  end
  
  paginates_per 50
  
  def game_type
    if self.game_type_id == 1
      new_game_type = GameTypes::IndividualStrokePlay.new
    elsif self.game_type_id == 2
      new_game_type = GameTypes::IndividualMatchPlay.new
    elsif self.game_type_id == 3
      new_game_type = GameTypes::IndividualModifiedStableford.new
    elsif self.game_type_id == 5
      new_game_type = GameTypes::TwoManShamble.new
    elsif self.game_type_id == 7
      new_game_type = GameTypes::TwoManScramble.new
    elsif self.game_type_id == 8
      new_game_type = GameTypes::FourManScramble.new
    elsif self.game_type_id == 10
      new_game_type = GameTypes::TwoManBestBall.new
    end
    
    new_game_type.tournament = self
    
    return new_game_type
  end
  
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