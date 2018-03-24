module Notifications
	class ScoreNotification
		def self.notify_for_score(score)
			tournament = score.scorecard.tournament_day.tournament
			complete_name = score.scorecard.user.complete_name
			strokes = score.strokes
			par = score.course_hole.par

			if strokes == 1
				notification_string = Notifications::NotificationStrings.hole_in_one(complete_name)
			elsif strokes = par - 1
				notification_string = Notifications::NotificationStrings.birdie(complete_name)
			end

			tournament.notify_tournament_users(notification_string, { tournament_id: tournament.id }) unless notification_string.blank?

			score.has_notified = true
		end
	end
end