class GolfOuting < ApplicationRecord
  include Servable

  belongs_to :tournament_group, inverse_of: :golf_outings, touch: true
  belongs_to :user
  belongs_to :course_tee_box
  has_one :scorecard, inverse_of: :golf_outing, :dependent => :destroy

  def disqualification_description
    if self.disqualified
      "Re-Qualify"
    else
      "Disqualify"
    end
  end

  def disqualify
    self.disqualified = !self.disqualified
    self.save

    golfer_team = self.tournament_group.tournament_day.golfer_team_for_player(self.user)
    unless golfer_team.blank?
      golfer_team.users.each do |u|
        team_outing = self.tournament_group.tournament_day.golf_outing_for_player(u)
        team_outing.disqualified = !team_outing.disqualified unless u == user
        team_outing.save
      end
    end
  end

end
