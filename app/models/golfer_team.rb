class GolferTeam < ApplicationRecord
  include Servable

  belongs_to :tournament_day, touch: true
  belongs_to :tournament_group, touch: true
  has_and_belongs_to_many :users
  has_many :golfer_teams, class_name: "GolferTeam", foreign_key: "parent_team_id"
  belongs_to :parent_team, class_name: "GolferTeam", touch: true

  validate :players_are_valid, on: :update
  def players_are_valid
    other_teams = self.tournament_day.golfer_teams

    self.users.each do |u|
      other_teams.each do |other_team|
        if other_team != self
          errors.add(:user_ids, "can't include a user that's already on another team") if other_team.users.include? u
        end
      end
    end
  end

  def team_number_label
    "Team ##{self.team_number} For Group"
  end

  def name
    complete_name = ""

    self.users.each do |u|
      complete_name += u.complete_name

      complete_name += " / " unless self.users.last == u
    end

    return complete_name
  end

  def short_name
    complete_name = ""

    self.users.each do |u|
      complete_name += u.first_name + " " + u.last_name + "."

      complete_name += " / " unless self.users.last == u
    end

    return complete_name
  end

end
