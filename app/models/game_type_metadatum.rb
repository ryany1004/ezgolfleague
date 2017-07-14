class GameTypeMetadatum < ApplicationRecord
  belongs_to :course_hole
  belongs_to :scorecard, touch: true
  belongs_to :golfer_team, touch: true
end
