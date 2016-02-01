class FinalizeJob < ProgressJob::Base
  def initialize(tournament)
    super progress_max: tournament.tournament_days.count * 3
    
    @tournament = tournament
  end

  def perform
    update_stage('Finalizing Tournament')

    @tournament_days = @tournament.tournament_days.includes(tournament_groups: [golf_outings: [:user, scorecard: :scores]])

    @tournament_days.each do |day|
      day.score_users
      
      update_progress
      
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