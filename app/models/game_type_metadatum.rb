class GameTypeMetadatum < ApplicationRecord
  belongs_to :course_hole, optional: true
  belongs_to :scorecard, touch: true, optional: true
  belongs_to :daily_team, touch: true, optional: true
end
