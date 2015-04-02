class Tournament < ActiveRecord::Base
  belongs_to :league, inverse_of: :tournaments
  belongs_to :course, inverse_of: :tournaments
  
  paginates_per 50
end
