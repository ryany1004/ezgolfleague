class TournamentGroup < ApplicationRecord
  include Servable

  belongs_to :tournament_day, inverse_of: :tournament_groups, touch: true
  has_many :golf_outings, -> { order(:created_at) }, inverse_of: :tournament_group, dependent: :destroy
  has_many :users, ->{ order 'last_name, first_name' }, through: :golf_outings
  has_many :daily_teams, -> { order(:created_at) }, inverse_of: :tournament_group, dependent: :destroy

  paginates_per 50

  validates :tee_time_at, presence: true
  validates :max_number_of_players, :inclusion => 0..10

  after_create :create_daily_teams

  validate :date_is_valid
  def date_is_valid
    if tee_time_at.at_beginning_of_day < tournament_day.tournament_at.at_beginning_of_day
      errors.add(:tee_time_at, "can't be on a different day than the tournament")
    end

    if tee_time_at.at_end_of_day > tournament_day.tournament_at.at_end_of_day
      errors.add(:tee_time_at, "can't be on a different day than the tournament")
    end
  end

  def players_signed_up
    self.users
  end

  def create_daily_teams
    if self.tournament_day.needs_daily_teams?
      Rails.logger.debug { "create_daily_teams" }

      number_of_teams_to_create = self.max_number_of_players / self.tournament_day.users_per_daily_teams

      team_number = 1

      number_of_teams_to_create.times do
        DailyTeam.create(tournament_group: self, team_number: team_number)

        team_number += 1
      end
    else
      Rails.logger.info { "NOT create_daily_teams" }
    end
  end

  def golfer_outing_for_index(index)
    if index < self.golf_outings.count
      self.golf_outings[index]
    else
      nil
    end
  end

  def daily_team_for_user_or_index(user, index)
    if user.blank? #show in order
      exploded_teams = []

      self.daily_teams.each do |g|
        g.max_players.times do |t|
          exploded_teams << g
        end
      end

      if index < exploded_teams.count
        exploded_teams[index]
      else
        nil
      end
    else #find the team this user is signed up for
      self.tournament_day.daily_team_for_player(user)
    end
  end

  def user_for_index(index)
    if index < self.golf_outings.count
      self.golf_outings[index].user
    else
      nil
    end
  end

  def add_or_move_user_to_group(user)
    existing_outing = self.tournament_day.golf_outing_for_player(user)

    unless existing_outing.blank?
      existing_outing.tournament_group = self
      existing_outing.save
    else
      self.tournament_day.add_player_to_group(tournament_group: self, user: user)
    end
  end

  def formatted_tee_time
    if self.tournament_day.tournament.show_players_tee_times == true
      self.tee_time_at.to_s(:time_only)
    else
      "#{self.tee_time_at.to_s(:time_only)} - #{self.time_description}"
    end
  end

  def time_description
    count = self.tournament_day.tournament_groups.count
    index = self.tournament_day.tournament_groups.index(self)

    early = 0
    middle = (count / 3)
    late = (count / 3) * 2

    if index >= early && index < middle
      "Early"
    elsif index >= middle && index < late
      "Middle"
    else
      "Late"
    end
  end

  def api_time_description
    if self.tournament_day.tournament.show_players_tee_times == true
      self.tee_time_at.to_s(:time_only)
    else
      self.time_description
    end
  end

  def can_be_deleted?
    if self.golf_outings.count > 0
      false
    else
      true
    end
  end

  #date parsing
  def tee_time_at=(date)
    begin
      parsed = EzglCalendar::CalendarUtils.datetime_for_picker_date(date)
      super parsed
    rescue
      write_attribute(:tee_time_at, date)
    end
  end
end
