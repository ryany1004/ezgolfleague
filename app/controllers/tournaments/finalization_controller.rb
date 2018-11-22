module Tournaments
  class FinalizationController < TournamentsController
  	before_action :fetch_tournament, only: [:show, :update]

	  def show
	    @page_title = "Finalize Tournament"

	    if @tournament.can_be_finalized?
	      @stage_name = "finalize"

	      @tournament.run_finalize unless !params[:bypass_calc].blank?

	      @tournament_days = @tournament.tournament_days.includes(payout_results: [:flight, :user, :payout], tournament_day_results: [:user, :primary_scorecard], tournament_groups: [golf_outings: [:user, :scorecard]])
	    else
	      redirect_to league_tournament_flights_path(@tournament.league, @tournament), flash: { error: "This tournament cannot be finalized. Verify all flights and payouts exist and if this is a team tournament that all team-members are correctly registered in all contests. Only tournaments with scores can be finalized." }
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

	      @tournament.is_finalized = true
	      @tournament.save

	      @tournament.finalization_notifications.each do |n|
	        n.has_been_delivered = false
	        n.save
	      end

	      #bust the cache
	      @tournament.tournament_days.each do |day|
	        day.touch
	      end
	      
	      redirect_to league_tournaments_path(current_user.selected_league), flash: { success: "The tournament was successfully finalized." }
	    else
	      redirect_to league_tournaments_path(current_user.selected_league), flash: { error: "The tournament could not be finalized - it is missing required data." }
	    end
	  end
  end
end
