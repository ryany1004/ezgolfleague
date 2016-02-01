class FinalizeJob < ProgressJob::Base
  def initialize(tournament)
    super progress_max: tournament.tournament_days.count + 1
    
    @tournament = tournament
  end

  def perform
    update_stage('Finalizing Tournament')

    @tournament.tournament_days.each do |day|
      day.score_users
      
      day.assign_payouts_from_scores
      
      update_progress
      
      day.contests.each do |contest|
        contest.score_contest
      end
      
      update_progress
    end
    
    Rails.logger.info { "FinalizeJob Completed" }
  end
end