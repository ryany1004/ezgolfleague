module TournamentService
  module Finalizer
    extend self

    def call(tournament, should_email = true)
      tournament_days = tournament.tournament_days.includes(scoring_rules: [payout_results: [:flight, :user, :payout],
                                                            tournament_day_results: [:user, :primary_scorecard]],
                                                            tournament_groups: [golf_outings: [:user, scorecard: :scores]])

      tournament_days.each do |day|
        finalize_day(day)
      end

      rank_league_season(tournament.league_season)

      tournament.league.active_season&.touch

      send_finalize_event(tournament) if should_email
    end

    private

    def finalize_day(day)
      Rails.logger.info { "Finalize #{day.id}: Re-Scoring Users" }

      TournamentService::ShadowStrokePlay.call(day)
      day.reload

      day.score_all_rules
      day.scoring_rules.each(&:finalize)
      day.assign_payouts_all_rules
      day.touch

      Rails.logger.info { "Finalize #{day.id}: All Done!" }
    end

    def rank_league_season(league_season)
      RankLeagueSeasonJob.perform_later(league_season)
    end

    def send_finalize_event(tournament)
      tournament_url = "https://app.ezgolfleague.com/leagues/#{tournament.league.id}/tournaments/#{tournament.id}/finalize?bypass_calc=true"
      tournament_info = { tournament_name: tournament.name, league_name: tournament.league.name, tournament_url: tournament_url }

      email_addresses = nil
      email_addresses = tournament.league.dues_payment_receipt_email_addresses.split(',') if tournament.league.dues_payment_receipt_email_addresses.present?

      RecordEventJob.perform_later(email_addresses, 'A tournament was finalized', tournament_info) if email_addresses.present?
    end
  end
end
