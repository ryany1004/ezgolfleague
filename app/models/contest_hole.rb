class ContestHole < ApplicationRecord
  belongs_to :contest, touch: true
  belongs_to :course_hole, touch: true
  has_many :contest_results, dependent: :destroy

  def hole_number
    self.course_hole.hole_number
  end
end
