class FinalizeJob < ProgressJob::Base
  def initialize(tournament)
    super progress_max: (tournament.tournament_days.count * 2)
    
    @tournament = tournament
  end

  def perform
    update_stage('Finalizing Tournament')

    tournament_days = @tournament.tournament_days.includes(tournament_groups: [golf_outings: [:user, scorecard: :scores]])
    players = @tournament.players

    Rails.logger.info { "Finalize: Starting Job" }

    tournament_days.each do |day|      
      Rails.logger.info { "Finalize: Assigning Payouts" }
      day.assign_payouts_from_scores
      
      update_progress
      
      Rails.logger.info { "Finalize: Scoring Contests" }
      day.contests.each do |contest|
        contest.score_contest
      end
      
      day.touch
      
      update_progress
    end
    
    Rails.logger.info { "FinalizeJob Completed" }
  end
end