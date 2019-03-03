module ScoringRules

  class CourseHolesController < ::BaseController
    before_action :fetch_tournament
	  before_action :fetch_scoring_rule, only: [:edit, :update]

	  def edit
	    @stage_name = "hole_information"
	  end

	  def update
	    if @tournament_day.update(tournament_day_params)
	      @tournament.tournament_days.each do |day|
	        self.update_scores_for_course_holes(tournament_day: day)
	      end

	      redirect_to league_tournament_tournament_day_scoring_rules_path(current_user.selected_league, @tournament, @tournament.tournament_days.first), flash: { success: "The game type holes were successfully updated." }
	    else
	      render :edit
	    end
	  end

    def scoring_rule_params
      params.require(:scoring_rule).permit(scoring_rule_course_hole_ids: [])
    end

    def update_scores_for_course_holes(tournament_day:)
      eager_groups = TournamentGroup.includes(golf_outings: [{ scorecard: :scores }]).where(tournament_day: tournament_day)
      scorecard_base_scoring_rule = tournament_day.scorecard_base_scoring_rule

      eager_groups.each do |group|
        group.golf_outings.each do |golf_outing|
          scorecard_base_scoring_rule.course_holes.each_with_index do |hole, i|
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

    def tournament_day_params
      params.require(:tournament_day).permit(scoring_rules_attributes: [:id, course_hole_ids: []])
    end

    def fetch_tournament
      @tournament = self.fetch_tournament_from_user_for_tournament_id(params[:tournament_id])
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
    end

    def fetch_scoring_rule
      @scoring_rule = @tournament_day.scoring_rules.find(params[:scoring_rule_id])
    end
  end

end
