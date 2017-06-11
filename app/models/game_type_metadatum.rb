class GameTypeMetadatum < ApplicationRecord
  belongs_to :course_hole, touch: true
  belongs_to :scorecard, touch: true
  belongs_to :golfer_team, touch: true
end
