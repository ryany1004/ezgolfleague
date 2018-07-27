class Api::V1::LeaguesController < Api::V1::ApiBaseController
  before_action :protect_with_token

  respond_to :json

  def index
    leagues = @current_user.leagues

    respond_with(leagues) do |format|
      format.json { render :json => leagues, content_type: 'application/json' }
    end
  end

  def show
    if params[:id] == "0"
      league = @current_user.leagues.first
    else
      league = @current_user.leagues.find(params[:id])
    end

    league_season = league.active_season
    league_season = league.league_seasons.last if league_season.blank?

    rankings = league_season.league_season_ranking_groups

    respond_with(rankings) do |format|
      format.json { render :json => rankings, content_type: 'application/json' }
    end
  end

end
