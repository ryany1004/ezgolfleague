ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  fixtures :all

  def generate_scores_for_user_tournament_day(user, tournament_day)
    scorecard = tournament_day.primary_scorecard_for_user(user)
    
    strokes = []
    
    tournament_day.course_holes.each_with_index do |hole, i|
      scorecard.scores << Score.create(course_hole: hole, strokes: 1, sort_order: i)
    end
  end
  
end
