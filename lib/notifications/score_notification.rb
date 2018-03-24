module Notifications
	class ScoreNotification
		def self.notify_for_score(score)
			tournament = score.scorecard.tournament_day.tournament
			complete_name = score.scorecard.golf_outing.user.complete_name
			strokes = score.strokes
			par = score.course_hole.par
			include_metadata = false

			if strokes == 1
				notification_string = Notifications::NotificationStrings.hole_in_one(complete_name)
			elsif strokes = par - 1
				notification_string = Notifications::NotificationStrings.birdie(complete_name)
			end

			metadata = {}
			if include_metadata
				metadata = { tournament_id: tournament.id }
			end

			tournament.notify_tournament_users(notification_string, metadata) unless notification_string.blank?

			score.has_notified = true
		end
	end
end