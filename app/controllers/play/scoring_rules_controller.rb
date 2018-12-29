class Play::ScoringRulesController < Play::BaseController
  layout "golfer"

  before_action :fetch

  def index
  end

  def fetch
    @tournament = self.view_tournament_from_user_for_tournament_id(params[:tournament_id])
    @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
    @scoring_rules = @tournament_day.optional_scoring_rules
  end

end
