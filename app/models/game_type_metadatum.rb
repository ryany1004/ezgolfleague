class GameTypeMetadatum < ApplicationRecord
  belongs_to :course_hole
  belongs_to :scorecard, touch: true
  belongs_to :daily_team, touch: true
end
