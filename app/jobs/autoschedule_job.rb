class AutoscheduleJob < ProgressJob::Base
  def initialize(tournament_day)
    super progress_max: 1

    @tournament_day = tournament_day
  end

  def perform
    update_stage('Auto-Scheduling')

    @tournament_day.schedule_golfers

    update_progress
  end

end
