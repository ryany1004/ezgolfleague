class Tournament < ActiveRecord::Base
  belongs_to :league, inverse_of: :tournaments
  belongs_to :course, inverse_of: :tournaments
  has_and_belongs_to_many :course_holes
  
  paginates_per 50
end
