class ContestResult < ActiveRecord::Base
  belongs_to :contest, :touch => true
  belongs_to :contest_hole
  belongs_to :winner, :class_name => "User", :foreign_key => "winner_id"
  
  validates :winner, presence: true
  validates :result_value, presence: true
  validates :payout_amount, presence: true

  def location
    if !self.contest.blank?
      return "Tournament Overall"
    else
      return "Hole #{self.contest_hole.course_hole.hole_number}"
    end
  end
  
end
