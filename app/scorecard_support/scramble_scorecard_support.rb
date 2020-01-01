module ScrambleScorecardSupport
  METADATA_KEY = 'scramble_scorecard_for_best_ball_hole'

  def related_scorecards_for_user(user, only_human_scorecards = false)
    []
  end

	def other_group_members(user:)
	  other_members = []

	  team = tournament_day.daily_team_for_player(user)
	  team&.users&.each do |u|
	    other_members << u if u != user
	  end

	  other_members
	end

  def update_metadata(metadata)
    scorecard = Scorecard.find(metadata[:scorecard_id])
    tournament_day = scorecard.tournament_day
    team = tournament_day.daily_team_for_player(scorecard.golf_outing.user)
    course_hole = CourseHole.find(metadata[:course_hole_id])

    metadata = GameTypeMetadatum.find_or_create_by(daily_team: team, course_hole: course_hole, search_key: METADATA_KEY)
    metadata.scorecard = scorecard
    metadata.save
  end

  def selected_scorecard_for_score(score) # this is the one selected as the tee shot
    return nil if score.scorecard.golf_outing.blank?

    tournament_day = score.scorecard.tournament_day
    team = tournament_day.daily_team_for_player(score.scorecard.golf_outing.user)
    metadata = GameTypeMetadatum.find_by(daily_team: team, course_hole: score.course_hole, search_key: METADATA_KEY)

    metadata&.scorecard
  end
end
