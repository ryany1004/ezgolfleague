class ContestHole < ActiveRecord::Base
  belongs_to :contest
  belongs_to :course_hole
  has_many :contest_results, :dependent => :destroy
end
