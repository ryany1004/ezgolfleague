class Course < ApplicationRecord
  include Servable

  has_many :course_holes, -> { order(:hole_number) }, dependent: :destroy, inverse_of: :course

  has_many :course_tee_boxes, dependent: :destroy, inverse_of: :course
  accepts_nested_attributes_for :course_tee_boxes

  has_many :tournament_days, dependent: :destroy, inverse_of: :course

  validates :name, presence: true
  validates :name, uniqueness: { scope: [:street_address_1, :city] }

  paginates_per 50

  def complete_name
    if city.blank? || us_state.blank?
      name
    else
      "#{name} - #{city}, #{us_state}"
    end
  end

  def geocode
    return if street_address_1.blank?

    coordinates = Geocoder.coordinates("#{street_address_1}, #{city}, #{us_state}")

    return if coordinates.blank?

    self.latitude = coordinates[0]
    self.longitude = coordinates[1]
  end
end
