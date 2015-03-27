class League < ActiveRecord::Base
  validates :name, presence: true
  
  paginates_per 50
end
