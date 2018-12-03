module Tournaments
  class CourseHolesController < TournamentsController
	  before_action :fetch_tournament, only: [:edit, :update]

	  def edit
	    @stage_name = "hole_information"
	  end

	  def update
	    if @tournament.update(tournament_params)
	      @tournament.tournament_days.each do |day|
	        self.update_scores_for_course_holes(tournament_day: day)
	      end

	      redirect_to league_tournament_tournament_day_scoring_rules_path(current_user.selected_league, @tournament, @tournament.tournament_days.first), flash: { success: "The tournament holes were successfully updated. Please select a game type." }
	    else
	      render :edit
	    end
	  end

    def update_scores_for_course_holes(tournament_day:)
      eager_groups = TournamentGroup.includes(golf_outings: [{scorecard: :scores}]).where(tournament_day: tournament_day)

      eager_groups.each do |group|
        group.golf_outings.each do |golf_outing|
          tournament_day.course_holes.each_with_index do |hole, i|
            score = Score.where(scorecard: golf_outing.scorecard).where(sort_order: i).first

            unless score.blank?
              Rails.logger.debug { "Updating Score #{score.id} on scorecard #{score.scorecard.id} from course hole #{score.course_hole.id} to course hole #{hole.id}." }

              score.course_hole = hole
              score.save
            else
              Rails.logger.debug { "Could not find a score with sort_order #{i} on scorecard #{score.scorecard.id}." }
            end
          end
        end
      end
    end
  end
end
