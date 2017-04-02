class Course < ActiveRecord::Base
  include Servable

  has_many :course_holes, -> { order(:hole_number) }, :dependent => :destroy, inverse_of: :course

  has_many :course_tee_boxes, :dependent => :destroy, inverse_of: :course
  accepts_nested_attributes_for :course_tee_boxes

  has_many :tournament_days, :dependent => :destroy, inverse_of: :course

  validates :name, presence: true

  paginates_per 50

  def complete_name
    "#{self.name} - #{self.city}, #{self.us_state}"
  end

  def geocode
    unless self.street_address_1.blank?
      coordinates = Geocoder.coordinates("#{self.street_address_1}, #{self.city}, #{self.us_state}")

      unless coordinates.blank?
        self.latitude = coordinates[0]
        self.longitude = coordinates[1]
      end
    end
  end

end
