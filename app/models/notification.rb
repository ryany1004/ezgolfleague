class Notification < ApplicationRecord
  belongs_to :notification_template
  belongs_to :user

  validates :title, presence: true
  validates :body, presence: true
end
