module Notifications
  class NotificationStrings
    def self.first_time_finalize(tournament_name = 'your tournament')
      "#{tournament_name} - results have been posted."
    end

    def self.update_finalize(tournament_name = 'your tournament')
      "#{tournament_name} - results have been updated."
    end

    def self.hole_in_one(username, hole_number)
      "#{username} just shot a hole-in-one on hole #{hole_number}!"
    end

    def self.birdie(username, hole_number)
      "#{username} just shot a birdie on hole #{hole_number}."
    end
  end
end
