module ScoringRules

  class PayoutResultsController < ::BaseController
    before_action :fetch_tournament
    before_action :fetch_tournament_day
    before_action :fetch_scoring_rule
    before_action :fetch_payout_results, only: [:index]
    before_action :fetch_payout_result, only: [:edit, :update, :destroy]
    before_action :set_stage
    
    after_action :recalculate_league_season, only: [:create, :update, :destroy]
    
    def index
      @page_title = "Results"
    end
    
    def new
      @payout_result = PayoutResult.new
    end
    
    def create
      @payout_result = PayoutResult.new(payout_result_params)
      @payout_result.scoring_rule = @scoring_rule

      if @payout_result.save
        redirect_to league_tournament_tournament_day_scoring_rule_payout_results_path(@tournament.league, @tournament, @tournament_day, @scoring_rule), flash: { success: "The payout result was successfully added." }
      else
        render :new
      end
    end
    
    def edit
    end
    
    def update
      if @payout_result.update(payout_result_params)      
        redirect_to league_tournament_tournament_day_scoring_rule_payout_results_path(@tournament.league, @tournament, @tournament_day, @scoring_rule), flash: { success: "The payout result was successfully updated." }
      else      
        render :edit
      end
    end
    
    def destroy
      @payout_result.destroy
      
      redirect_to league_tournament_tournament_day_scoring_rule_payout_results_path(@tournament.league, @tournament, @tournament_day, @scoring_rule), flash: { success: "The payout result was successfully deleted." }
    end
    
    private
    
    def fetch_scoring_rule
      @scoring_rule = @tournament_day.scoring_rules.find(params[:scoring_rule_id])
    end
    
    def fetch_tournament
      @tournament = self.fetch_tournament_from_user_for_tournament_id(params[:tournament_id])
    end
    
    def fetch_payout_results
      @payout_results = @scoring_rule.payout_results
    end
    
    def fetch_payout_result
      @payout_result = @scoring_rule.payout_results.find(params[:id])
    end

    def payout_result_params
      params.require(:payout_result).permit(:user_id, :amount, :points, :detail, :scoring_rule_course_hole_id)
    end

    def fetch_tournament_day
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
    end
    
    def recalculate_league_season
    	RankLeagueSeasonJob.perform_later(@tournament.league_season) if @tournament.league_season.present?
    end

    def set_stage
      @stage_name = "payout_results"
    end
    
  end

end