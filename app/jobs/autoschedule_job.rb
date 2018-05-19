class AutoscheduleJob < ApplicationJob
  def perform(tournament_day)
  	Rails.logger.info { "AutoscheduleJob Starting" }

    tournament_day.schedule_golfers
  end
end
