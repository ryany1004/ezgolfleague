class MobileDevice < ApplicationRecord
  belongs_to :user

  validates :device_identifier, presence: true, uniqueness: true
end
