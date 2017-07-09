class ReportsController < BaseController
  before_action :fetch_tournament_day, except: [:index, :finalization_report]

  def index
    leagues = nil
    leagues = current_user.leagues unless current_user.is_super_user?

    @past_tournaments = Tournament.tournaments_happening_at_some_point(nil, nil, leagues, true).reorder("tournament_starts_at DESC").page(params[:page]).without_count

    @page_title = "Tournament Reports"
  end

  def finalization_report
    @past_tournaments = Tournament.tournaments_happening_at_some_point(nil, nil, nil, true).where(is_finalized: true).reorder("tournament_starts_at DESC").page(params[:page]).without_count
  end

  def adjusted_scores
    @report = Reports::AdjustedScores.new(@tournament_day)

    @page_title = "Adjusted Score Report"
  end

  def confirmed_players
    @page_title = "Payment and Confirmation Report"

    @eager_groups = TournamentGroup.includes(golf_outings: [{scorecard: :scores}, :user]).where(tournament_day: @tournament_day).order(:tee_time_at)
  end

  def fetch_tournament_day
    @tournament = Tournament.find(params[:tournament])

    if params[:tournament_day].blank?
      @tournament_day = @tournament.first_day
    else
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day])
    end
  end

end
