class MobileDevice < ApplicationRecord
  belongs_to :user, touch: true

  validates :device_identifier, presence: true, uniqueness: true
end
