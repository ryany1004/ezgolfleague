class CourseHole < ApplicationRecord
  belongs_to :course, inverse_of: :course_holes, touch: true
  has_many :scoring_rule_course_holes, inverse_of: :course_hole, dependent: :destroy
  has_many :course_hole_tee_boxes, -> { order(yardage: :desc) }, dependent: :destroy, inverse_of: :course_hole
  accepts_nested_attributes_for :course_hole_tee_boxes

  validates :par, inclusion: 1..7

  def name
    "##{hole_number} (Par #{par})"
  end

  def yardage_strings
    if course_hole_tee_boxes.blank?
      ['N/A']
    else
      yardage_strings = []

      course_hole_tee_boxes.includes(:course_tee_box).find_each do |b|
        yardage_strings << "#{b.course_tee_box.name} - #{b.yardage}" if b.course_tee_box.present?
      end

      yardage_strings
    end
  end

  def yards_for_flight(flight)
    tee_box_name = flight&.course_tee_box&.name

    yardage = 0

    course_hole_tee_boxes.includes(:course_tee_box).find_each do |b|
      yardage = b.yardage if b.course_tee_box.name == tee_box_name
    end

    yardage
  end
end
