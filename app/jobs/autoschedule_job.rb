class AutoscheduleJob < ApplicationJob
  def perform(tournament_day)
    Rails.logger.info { "AutoscheduleJob Starting for Day #{tournament_day.id}" }

    tournament_day.schedule_golfers
  end
end
