class ScoringRulesController < BaseController
  before_action :fetch_tournament
  before_action :fetch_scoring_rule, only: [:edit, :update, :destroy]
  before_action :set_stage
  
  def index
  	@scoring_rules = @tournament_day.scoring_rules
  end

  def create
  	scoring_rule = params[:scoring_rule][:selected_class_name].constantize.new(tournament_day: @tournament_day)
    scoring_rule.is_opt_in = scoring_rule.optional_by_default
    scoring_rule.save

    #default course holes
    @tournament_day.course.course_holes.each do |ch|
      scoring_rule.course_holes << ch
    end

  	redirect_to edit_league_tournament_tournament_day_scoring_rule_path(@tournament.league, @tournament, @tournament_day, scoring_rule)
  end

  def update
    @scoring_rule.update(scoring_rule_params)

    if params[:scoring_rule_options].blank? || params[:scoring_rule_options][@scoring_rule.id.to_s].blank?
      @scoring_rule.remove_game_type_options
    else
  		@scoring_rule.save_setup_details(params[:scoring_rule_options][@scoring_rule.id.to_s])
  	end

    #if mandatory, add users
    if (!@scoring_rule.is_opt_in && @scoring_rule.users.empty?) && @tournament_day.scorecard_base_scoring_rule.users.count > 0
      @scoring_rule.users += @tournament_day.scorecard_base_scoring_rule.users
    end

    #handle daily teams if the rule requires
    if @scoring_rule.team_type == ScoringRuleTeamType::DAILY && @tournament_day.daily_teams.count == 0
      @tournament_day.tournament_groups.each do |group|
        group.create_daily_teams
      end
    end

  	@scoring_rule.tournament_day_results.destroy_all #removed cached results as gametype influences scores

  	redirect_to league_tournament_tournament_day_scoring_rules_path(@tournament.league, @tournament, @tournament_day)
  end
  
	def destroy
    @scoring_rule.destroy

    redirect_to league_tournament_tournament_day_scoring_rules_path(@tournament.league, @tournament, @tournament_day)
  end

  private

  def scoring_rule_params
    params.require(:scoring_rule).permit(:dues_amount, :is_opt_in)
  end
  
  def scoring_rule_class_for_name(name)
  	name.constantize
  end
  
  def fetch_tournament
    @tournament = self.fetch_tournament_from_user_for_tournament_id(params[:tournament_id])
    @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
  end

  def fetch_scoring_rule
  	@scoring_rule = @tournament_day.scoring_rules.find(params[:id])
  end
  
  def set_stage
    @stage_name = "scoring_rules"
  end
end
