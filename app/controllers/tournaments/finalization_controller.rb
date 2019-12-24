module Tournaments
  class FinalizationController < TournamentsController
    before_action :fetch_tournament, only: [:update]

    def update
      if @tournament.can_be_finalized?
        if !@tournament.is_finalized
          notification_string = Notifications::NotificationStrings.first_time_finalize(@tournament.name)
        else
          notification_string = Notifications::NotificationStrings.update_finalize(@tournament.name)
        end
        @tournament.notify_tournament_users(notification_string, { tournament_id: @tournament.id })

        TournamentService::Finalizer.call(@tournament)

        @tournament.update(is_finalized: true)

        @tournament.finalization_notifications.each do |n|
          n.has_been_delivered = false
          n.save
        end

        SendEventToDripJob.perform_later('Finalized a tournament', user: current_user, options: { tournament: { name: @tournament.name } })

        # bust the cache
        @tournament.tournament_days.each do |day|
          day.touch
        end

        redirect_to league_tournament_path(current_user.selected_league, @tournament), flash: { success: 'The tournament was successfully finalized.' }
      else
        redirect_to league_tournament_path(current_user.selected_league, @tournament), flash: { error: 'The tournament could not be finalized - it is missing required data.' }
      end
    end
  end
end
