class GolfOuting < ActiveRecord::Base
  belongs_to :team, inverse_of: :golf_outings
  belongs_to :user
  belongs_to :course_tee_box
  has_many :scorecards, inverse_of: :golf_outing, :dependent => :destroy
end
