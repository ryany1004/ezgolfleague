class GolfOuting < ApplicationRecord
  include Servable

  acts_as_paranoid

  belongs_to :tournament_group, inverse_of: :golf_outings, optional: true, touch: true
  belongs_to :user, inverse_of: :golf_outings
  belongs_to :course_tee_box, optional: true
  has_one :scorecard, inverse_of: :golf_outing, dependent: :destroy

  validates :course_handicap, presence: true

  def tournament
    tournament_group&.tournament_day&.tournament
  end

  def team_combined_name
    if tournament_group.daily_teams.count.zero?
      nil
    else
      daily_team = tournament_group.daily_team_for_user_or_index(user, 0)

      if daily_team.blank?
        'No Team Found'
      else
        daily_team.short_name
      end
    end
  end

  def in_league?(league)
    tournament_group.tournament_day.tournament.league == league
  end

  def disqualification_description
    if disqualified
      'Re-Qualify'
    else
      'Disqualify'
    end
  end

  def lock_handicap
    update(handicap_lock: true)
  end

  def disqualify
    self.disqualified = !disqualified
    save

    # handle scoring rules
    tournament_group.tournament_day.scoring_rules.each do |rule|
      rule.scoring_rule_participations.where(user: user).find_each do |p|
        p.disqualified = !p.disqualified
        p.save
      end
    end

    # handle daily teams
    daily_team = tournament_group.tournament_day.daily_team_for_player(user)
    return if daily_team.blank?

    daily_team.users.each do |u|
      team_outing = tournament_group.tournament_day.golf_outing_for_player(u)
      team_outing.disqualified = !team_outing.disqualified unless u == user
      team_outing.save
    end
  end
end
