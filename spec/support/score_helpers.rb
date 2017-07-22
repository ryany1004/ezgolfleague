module ScoreHelpers
  def add_to_group_and_create_scores(tournament_day, user, group, strokes = nil)
    strokes = [1,1,6,4,6,3,5,6,5,7,6,5,3,6,6,5,3,10] if strokes.blank?

    tournament_day.add_player_to_group(group, user)

    scorecard = tournament_day.primary_scorecard_for_user(user)
    scorecard.scores.destroy_all #remove the 0 based scores

    tournament_day.course_holes.each_with_index do |hole, i|
      Score.create(scorecard: scorecard, course_hole: hole, strokes: strokes[i], sort_order: i)
    end

    tournament_day.score_users

    scorecard.tournament_day.game_type.after_updating_scores_for_scorecard(scorecard)

    other_scorecards = []
    scorecard.tournament_day.other_group_members(user).each do |m|
      other_scorecards << tournament_day.primary_scorecard_for_user(m)
    end

    other_scorecards.each do |other_scorecard|
      unless other_scorecard.golf_outing.blank?
        scorecard.tournament_day.score_user(other_scorecard.golf_outing.user)
        scorecard.tournament_day.game_type.after_updating_scores_for_scorecard(other_scorecard)
      end
    end
  end
end

RSpec.configure do |c|
  c.include ScoreHelpers
end
