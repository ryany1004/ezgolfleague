class FinalizeJob < ProgressJob::Base
  def initialize(tournament)
    super progress_max: (tournament.tournament_days.count * 4)

    @tournament = tournament
  end

  def perform
    update_stage('Finalizing Tournament')

    tournament_days = @tournament.tournament_days.includes(tournament_groups: [golf_outings: [:user, scorecard: :scores]])

    Rails.logger.info { "Finalize: Starting Job" }

    tournament_days.each do |day|
      update_progress

      Rails.logger.info { "Finalize #{day.id}: Re-Scoring Users" }
      day.score_users

      update_progress

      Rails.logger.info { "Finalize #{day.id}: Assigning Payouts" }
      day.assign_payouts_from_scores

      update_progress

      Rails.logger.info { "Finalize #{day.id}: Scoring Contests" }
      day.contests.each do |contest|
        contest.score_contest
      end

      Rails.logger.info { "Finalize #{day.id}: All Done!" }

      day.touch

      update_progress
    end

    if @tournament.subscription_credit.blank?
      subscription_to_attach = @tournament.league.subscription_credits.where("tournaments_remaining > 0").order("created_at").limit(1).first

      unless subscription_to_attach.blank?
        @tournament.subscription_credit = subscription_to_attach
        @tournament.save

        subscription_to_attach.tournaments_remaining = subscription_to_attach.tournaments_remaining - 1
        subscription_to_attach.save
      end
    end

    #cache bust
    @tournament.league.active_season.touch unless @tournament.league.active_season.blank?

    #email completion
    LeagueMailer.tournament_finalized(@tournament).deliver_later unless @tournament.league.dues_payment_receipt_email_addresses.blank?

    Rails.logger.info { "FinalizeJob Completed" }
  end
end
