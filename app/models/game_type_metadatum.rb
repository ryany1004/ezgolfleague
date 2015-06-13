class GameTypeMetadatum < ActiveRecord::Base
  belongs_to :course_hole
  belongs_to :scorecard
  belongs_to :golfer_team
end
