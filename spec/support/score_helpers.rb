module ScoreHelpers
  def add_to_group_and_create_scores(tournament_day, user, group, strokes = nil)
    tournament_day.add_player_to_group(group, user)

    scorecard = tournament_day.primary_scorecard_for_user(user)
    strokes = [1,1,6,4,6,3,5,6,5,7,6,5,3,6,6,5,3,10] if strokes.blank?

    scorecard.scores.destroy_all #remove the 0 based scores

    tournament_day.course_holes.each_with_index do |hole, i|
      Score.create(scorecard: scorecard, course_hole: hole, strokes: strokes[i], sort_order: i)
    end

    tournament_day.score_users
  end
end

RSpec.configure do |c|
  c.include ScoreHelpers
end
