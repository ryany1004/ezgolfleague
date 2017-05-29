class TournamentGroup < ActiveRecord::Base
  include Servable

  belongs_to :tournament_day, inverse_of: :tournament_groups, touch: true
  has_many :golf_outings, -> { order(:created_at) }, inverse_of: :tournament_group, :dependent => :destroy
  has_many :golfer_teams, -> { order(:created_at) }, inverse_of: :tournament_group, :dependent => :destroy

  paginates_per 50

  after_create :create_golfer_teams

  def create_golfer_teams
    if self.tournament_day.tournament.display_teams?
      number_of_teams_to_create = self.max_number_of_players / self.tournament_day.game_type.number_of_players_per_team

      team_number = 1

      number_of_teams_to_create.times do
        GolferTeam.create(tournament_day: self.tournament_day, tournament_group: self, team_number: team_number)

        team_number += 1
      end
    end
  end

  def players_signed_up
    players = []

    self.golf_outings.includes(:user).each do |g|
      players << g.user unless g.user.blank?
    end

    return players
  end

  def golfer_outing_for_index(index)
    if index < self.golf_outings.count
      return self.golf_outings[index]
    else
      return nil
    end
  end

  def golfer_team_for_user_or_index(user, index)
    if user.blank? #show in order
      exploded_teams = []

      self.golfer_teams.each do |g|
        g.max_players.times do |t|
          exploded_teams << g
        end
      end

      if index < exploded_teams.count
        return exploded_teams[index]
      else
        return nil
      end
    else #find the team this user is signed up for
      return self.tournament_day.golfer_team_for_player(user)
    end
  end

  def user_for_index(index)
    if index < self.golf_outings.count
      return self.golf_outings[index].user
    else
      return nil
    end
  end

  def add_or_move_user_to_group(user)
    existing_outing = self.tournament_day.golf_outing_for_player(user)

    unless existing_outing.blank?
      existing_outing.tournament_group = self
      existing_outing.save
    else
      self.tournament_day.add_player_to_group(self, user)
    end
  end

  def formatted_tee_time
    if self.tournament_day.tournament.show_players_tee_times == true
      return self.tee_time_at.to_s(:time_only)
    else
      return "#{self.tee_time_at.to_s(:time_only)} - #{self.time_description}"
    end
  end

  def time_description
    count = self.tournament_day.tournament_groups.count
    index = self.tournament_day.tournament_groups.index(self)

    early = 0
    middle = (count / 3)
    late = (count / 3) * 2

    if index >= early && index < middle
      return "Early"
    elsif index >= middle && index < late
      return "Middle"
    else
      return "Late"
    end
  end

  def api_time_description
    if self.tournament_day.tournament.show_players_tee_times == true
      return self.tee_time_at.to_s(:time_only)
    else
      return self.time_description
    end
  end

  def can_be_deleted?
    if self.golf_outings.count > 0
      return false
    else
      return true
    end
  end

  #date parsing
  def tee_time_at=(date)
    begin
      parsed = DateTime.strptime("#{date} #{Time.zone.now.formatted_offset}", JAVASCRIPT_DATETIME_PICKER_FORMAT)
      super parsed
    rescue
      write_attribute(:tee_time_at, date)
    end
  end

  #JSON

  def as_json(options={})
    Rails.cache.fetch("groups-json#{self.id}-#{self.updated_at.to_s}-#{self.tournament_day.updated_at.to_s}") do
      super(
        :only => [:tee_time_at, :max_number_of_players],
        :methods => [:server_id, :api_time_description],
        :include => {
          :golf_outings => {
            :only => [:course_handicap],
            :methods => [:server_id],
            :include => {
              :user => {
                :only => [:first_name, :last_name],
                :methods => [:server_id, :avatar_image_url]
              },
              :course_tee_box => {
                :only => [:name],
                :methods => [:server_id]
              },
              :scorecard => {
                :only => [:id],
                :methods => [:server_id],
                :include => {
                  :scores => {
                    :only => [:id, :strokes],
                    :methods => [:server_id, :course_hole_number, :course_hole_par, :course_hole_yards, :tee_group_name]
                  }
                }
              }
            }
          }
        }
      )
    end
  end

end
