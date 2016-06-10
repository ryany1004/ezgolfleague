class GolfOuting < ActiveRecord::Base
  include Servable

  belongs_to :tournament_group, inverse_of: :golf_outings
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
end
