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
    league = @current_user.leagues.find(params[:id])
    league_season = league.active_season
    league_season = league.league_seasons.last if league_season.blank?

    rankings = league.ranked_users_for_league_season(league_season)

    respond_with(rankings) do |format|
      format.json { render :json => rankings, content_type: 'application/json' }
    end
  end

end
