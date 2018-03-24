module Notifications
	class NotificationStrings
	
		def self.first_time_finalize(tournament_name = "your tournament")
			return "Final results are now available for #{tournament_name}."
		end

		def self.update_finalize(tournament_name = "your tournament")
			return "Final results have been updated for #{tournament_name}."
		end

		def self.hole_in_one(username)
			return "#{username} just shot a hole-in-one!"
		end

		def self.birdie(username)
			return "#{username} just shot a birdie."
		end

	end
end