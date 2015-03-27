class League < ActiveRecord::Base
  has_many :users, through: :league_memberships
  
  validates :name, presence: true
  
  paginates_per 50
end
