class AutoscheduleJob < ApplicationJob
  def perform(tournament_day)
    tournament_day.schedule_golfers
  end
end
