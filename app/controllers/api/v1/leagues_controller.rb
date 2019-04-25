class Api::V1::LeaguesController < Api::V1::ApiBaseController
  before_action :protect_with_token

  respond_to :json

  def index
    @leagues = @current_user.leagues
  end

  def show
    if params[:id] == '0'
      league = @current_user.leagues.first
    else
      league = @current_user.leagues.find(params[:id])
    end

    if league.present?
      league_season = league.active_season
      league_season = league.league_seasons.last if league_season.blank?

      @rankings = league_season.league_season_ranking_groups
    else
      render json: { success: false }, status: :bad_request
    end
  end
end
