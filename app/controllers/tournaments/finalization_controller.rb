module Tournaments
  class FinalizationController < TournamentsController
    before_action :fetch_tournament, only: [:show, :update]

    def show
      @page_title = 'Finalize Tournament'

      if @tournament.can_be_finalized?
        @stage_name = 'finalize'

        @tournament.run_finalize if params[:bypass_calc].blank?

        @tournament_days = @tournament.tournament_days.includes(scoring_rules:
                                                               [payout_results: [:flight, :user, :payout],
                                                                tournament_day_results: [:user, :primary_scorecard]],
                                                                tournament_groups: [golf_outings: [:user, scorecard: :scores]])
      else
        finalization_blockers = @tournament.finalization_blockers

        redirect_to league_tournament_tournament_day_flights_path(@tournament.league, @tournament, @tournament.tournament_days.first), flash:
        { error: "This tournament cannot be finalized. #{finalization_blockers.join(' ')}" }
      end
    end

    def update
      if @tournament.can_be_finalized?
        if !@tournament.is_finalized
          notification_string = Notifications::NotificationStrings.first_time_finalize(@tournament.name)
        else
          notification_string = Notifications::NotificationStrings.update_finalize(@tournament.name)
        end
        @tournament.notify_tournament_users(notification_string, { tournament_id: @tournament.id })
        @tournament.update(is_finalized: true)

        @tournament.finalization_notifications.each do |n|
          n.has_been_delivered = false
          n.save
        end

        SendEventToDripJob.perform_later('Finalized a tournament', user: current_user, options: { tournament: { name: @tournament.name } })

        # bust the cache
        @tournament.tournament_days.each(&:touch)

        redirect_to league_tournaments_path(current_user.selected_league), flash:
        { success: 'The tournament was successfully finalized.' }
      else
        redirect_to league_tournaments_path(current_user.selected_league), flash:
        { error: 'The tournament could not be finalized - it is missing required data.' }
      end
    end
  end
end
