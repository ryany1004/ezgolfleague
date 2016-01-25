ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  fixtures :all

  def generate_scores_for_user_tournament_day(user, tournament_day, strokes = nil)
    scorecard = tournament_day.primary_scorecard_for_user(user)
    
    strokes = [1,1,6,4,6,3,5,6,5,7,6,5,3,6,6,5,3,10] if strokes.blank?
    
    tournament_day.course_holes.each_with_index do |hole, i|
      Score.create(scorecard: scorecard, course_hole: hole, strokes: strokes[i], sort_order: i)
    end
  end
  
end
