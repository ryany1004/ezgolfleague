class DailyTeam < ApplicationRecord
  include Servable

  belongs_to :tournament_group, touch: true
  has_and_belongs_to_many :users, -> { order(:last_name, :first_name) }, dependent: :nullify, inverse_of: :daily_teams
  has_many :daily_teams, class_name: 'DailyTeam', foreign_key: 'parent_team_id', inverse_of: :parent_team, dependent: :nullify
  belongs_to :parent_team, class_name: 'DailyTeam', touch: true, optional: true

  validate :players_are_valid, on: :update
  def players_are_valid
    other_teams = tournament_day.daily_teams

    users.each do |u|
      other_teams.each do |other_team|
        if other_team != self
          errors.add(:user_ids, 'can\'t include a user that\'s already on another team') if other_team.users.include? u
        end
      end
    end
  end

  def team_number_label
    "Pairing ##{team_number} For Group"
  end

  def name
    complete_name = ''

    users.each do |u|
      complete_name += u.complete_name

      complete_name += ' / ' unless users.last == u
    end

    complete_name
  end

  def short_name
    complete_name = ''

    users.each do |u|
      complete_name += u.first_name + ' ' + u.last_name[0] + '.'

      complete_name += ' / ' unless users.last == u
    end

    complete_name
  end
end
