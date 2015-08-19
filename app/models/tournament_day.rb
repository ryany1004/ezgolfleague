class TournamentDay < ActiveRecord::Base
  include Addable
  include Scoreable
  include FindPlayers
  include AutoSchedulable
  
  belongs_to :tournament, inverse_of: :tournament_days, :touch => true
  belongs_to :course, inverse_of: :tournament_days
  has_many :tournament_groups, -> { order(:tee_time_at) }, inverse_of: :tournament_day, :dependent => :destroy
  has_many :flights, -> { order(:flight_number) }, inverse_of: :tournament_day, :dependent => :destroy
  has_many :contests, inverse_of: :tournament_day, :dependent => :destroy
  has_many :golfer_teams, inverse_of: :tournament_day, :dependent => :destroy
  has_many :tournament_day_results, inverse_of: :tournament_day, :dependent => :destroy
  has_and_belongs_to_many :course_holes, -> { order(:hole_number) }
  
  attr_accessor :skip_date_validation
  
  delegate :player_score, :compute_player_score, :player_points, :flights_with_rankings, :related_scorecards_for_user, :assign_payouts_from_scores, to: :game_type
  delegate :allow_teams, :show_teams?, :players_create_teams?, :show_team_scores_for_all_teammates?, to: :game_type
  delegate :other_group_members, :user_is_in_group?, to: :game_type
  delegate :handicap_allowance, to: :game_type
  delegate :can_be_played?, :can_be_finalized?, to: :game_type
  
  validates :tournament_at, presence: true
  
  validate :dates_are_valid, on: :create, unless: "self.skip_date_validation == true"
  def dates_are_valid
    now = Time.zone.now.at_beginning_of_day
  
    if tournament_at.present? && tournament_at < now
      errors.add(:tournament_at, "can't be in the past")
    end
  end
  
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
    elsif self.game_type_id == 11
      new_game_type = GameTypes::TwoBestBallsOfFour.new
    elsif self.game_type_id == 12
      new_game_type = GameTypes::TwoManComboScrambleBestBall.new
    end
    
    new_game_type.tournament_day = self
    
    return new_game_type
  end
  
  def pretty_day(add_space = false)
    return nil if self.tournament.tournament_days.count == 1
    
    day_index = 0
    
    self.tournament.tournament_days.each_with_index do |d, i|
      day_index = i if d == self
    end
    
    day_string = "Day #{day_index + 1}"
    day_string = day_string + " " if add_space == true

    return day_string
  end
  
  def has_payouts?
    self.flights.each do |flight|
      return true if flight.payouts.count > 0
    end

    return false
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
end
