module Tournaments
  class AutoSchedulingController < TournamentsController
	  before_action :fetch_tournament, only: [:update, :run_auto_scheduling]

	  def update
	    if @tournament.update(tournament_params)
	      redirect_to league_tournament_day_players_path(@tournament.league, @tournament, @tournament.tournament_days.first), flash: { success: "The scoring mechanism was updated." }
	    end
	  end

	  def run_auto_scheduling
	    groups_error = false
	    @tournament.tournament_days.each do |day|
	      groups_error = true if day.tournament_groups.count == 0
	    end

	    if groups_error == true
	      redirect_to league_tournaments_path(current_user.selected_league), flash: { error: "One or more days had no tee-times. Re-scheduling was aborted." }
	    else
	      @tournament.tournament_days.each do |day|
	        AutoscheduleJob.perform_later(day) if day.has_scores? == false
	      end
	      redirect_to league_tournaments_path(current_user.selected_league), flash: { success: "Days without scores were submitted to be auto-scheduled. This usually takes a few minutes, depending on the size of the tournament." }
	    end
	  end
  end
end
