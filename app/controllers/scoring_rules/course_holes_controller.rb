module ScoringRules
  class CourseHolesController < ::BaseController
    before_action :fetch_tournament
    before_action :fetch_scoring_rule, only: [:edit, :update]

    def edit
      @stage_name = 'hole_information'
    end

    def update
      if @tournament_day.update(tournament_day_params)
        @tournament.tournament_days.each do |day|
          update_scores_for_course_holes(tournament_day: day)
        end

        redirect_to league_tournament_tournament_day_scoring_rules_path(current_user.selected_league, @tournament, @tournament.tournament_days.first), flash:
        { success: 'The game type holes were successfully updated.' }
      else
        render :edit
      end
    end

    def scoring_rule_params
      params.require(:scoring_rule).permit(scoring_rule_course_hole_ids: [])
    end

    def update_scores_for_course_holes(tournament_day:)
      return if tournament_day.has_scores?

      tournament_day.eager_groups.each do |group|
        group.golf_outings.each do |golf_outing|
          scorecard = golf_outing.scorecard

          tournament_day.update_scores_for_scorecard(scorecard: scorecard)

          golf_outing.user.send_silent_notification({ action: 'update', tournament_id: tournament_day.tournament.id, tournament_day_id: tournament_day.id })
        end
      end
    end

    def tournament_day_params
      params.require(:tournament_day).permit(scoring_rules_attributes: [:id, course_hole_ids: []])
    end

    def fetch_tournament
      @tournament = fetch_tournament_from_user_for_tournament_id(params[:tournament_id])
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
    end

    def fetch_scoring_rule
      @scoring_rule = @tournament_day.scoring_rules.find(params[:scoring_rule_id])
    end
  end
end
