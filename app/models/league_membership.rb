class LeagueMembership < ActiveRecord::Base
  belongs_to :league
  belongs_to :user
  
  validates :league, presence: true
  validates :user, presence: true
  
end
