module Notifications
	class ScoreNotification
		def self.notify_for_score(score)
			tournament = score.scorecard.tournament_day.tournament
			complete_name = score.scorecard.golf_outing.user.complete_name
			strokes = score.strokes
			par = score.course_hole.par
			include_metadata = false

			if strokes == 1
				notification_string = Notifications::NotificationStrings.hole_in_one(complete_name, score.course_hole_number)
			elsif strokes == (par - 1)
				notification_string = Notifications::NotificationStrings.birdie(complete_name, score.course_hole_number)
			end

			metadata = {}
			if include_metadata == true
				metadata = { tournament_id: tournament.id }
			end

			if notification_string.present?
				Rails.logger.info { "Score Notification String: (#{complete_name}, #{score.id}, #{strokes}, #{par}) #{notification_string}" }

				tournament.notify_tournament_users(notification_string, metadata)
			end
		end
	end
end