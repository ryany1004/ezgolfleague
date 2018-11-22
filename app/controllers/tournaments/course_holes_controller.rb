module Tournaments
  class CourseHolesController < TournamentsController
	  before_action :fetch_tournament, only: [:edit, :update]

	  def edit
	    @stage_name = "hole_information"
	  end

	  def update
	    if @tournament.update(tournament_params)
	      @tournament.tournament_days.each do |day|
	        day.update_scores_for_course_holes
	      end

	      redirect_to league_tournament_tournament_day_scoring_rules_path(current_user.selected_league, @tournament, @tournament.tournament_days.first), flash: { success: "The tournament holes were successfully updated. Please select a game type." }
	    else
	      render :edit
	    end
	  end
  end
end
