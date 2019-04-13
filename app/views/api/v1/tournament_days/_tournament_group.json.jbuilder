json.cache! ['v1', tournament_group] do
	json.server_id							tournament_group.server_id
	json.api_time_description		tournament_group.api_time_description
	json.tee_time_at						tournament_group.tee_time_at
	json.show_players_tee_times tournament_group.tournament_day.tournament.show_players_tee_times
	json.max_number_of_players	tournament_group.max_number_of_players

	json.golf_outings tournament_group.api_golf_outings do |golf_outing|
		json.server_id							golf_outing.server_id
		json.course_handicap				golf_outing.course_handicap.to_i
		json.team_combined_name			golf_outing.team_combined_name

		json.user do
			json.server_id						golf_outing.user.server_id
			json.avatar_image_url			golf_outing.user.avatar_image_url
			json.first_name						golf_outing.user.first_name
			json.last_name						golf_outing.user.last_name
		end

		json.course_tee_box do
			json.server_id						golf_outing.course_tee_box.server_id
			json.name 								golf_outing.course_tee_box.name
		end

		json.scorecard do
			json.id 									golf_outing.scorecard.id
			json.server_id						golf_outing.scorecard.server_id

			json.scores golf_outing.scorecard.scores do |score|
				json.server_id					score.server_id
				json.id 								score.id
				json.strokes						score.strokes
				json.course_hole_number	score.course_hole_number
				json.course_hole_par		score.course_hole_par
				json.course_hole_yards	score.course_hole_yards
				json.tee_group_name			score.tee_group_name
			end
		end
	end
end