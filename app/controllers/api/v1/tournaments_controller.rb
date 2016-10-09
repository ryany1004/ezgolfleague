class Api::V1::TournamentsController < Api::V1::ApiBaseController
  before_filter :protect_with_token, except: [:app_association]

  respond_to :json

  def index
    all_tournaments = Rails.cache.fetch(self.user_tournaments_cache_key, expires_in: 2.minutes, race_condition_ttl: 10)
    if all_tournaments.blank?
      logger.info { "Fetching Tournaments - Not Cached" }

      todays_tournaments = Tournament.all_today(@current_user.leagues)
      upcoming_tournaments = Tournament.all_upcoming(@current_user.leagues, nil)
      past_tournaments = Tournament.all_past(@current_user.leagues, nil).limit(5)

      all_tournaments = todays_tournaments + upcoming_tournaments + past_tournaments.to_a

      Rails.cache.write(self.user_tournaments_cache_key, all_tournaments)
    else
      logger.info { "Returning Cached Tournaments" }
    end

    respond_with(all_tournaments) do |format|
      format.json { render :json => all_tournaments }
    end
  end

  def app_association
    render json: {
      webcredentials: {
        apps: ["9F3JLFC8C4.com.ezgolfleague.GolfApp"]
      }
    }
  end

  def user_tournaments_cache_key
    max_updated_at = Tournament.all_upcoming(@current_user.leagues, nil).maximum(:updated_at).try(:utc).try(:to_s, :number)

    return "APITournaments-#{@current_user.id}-#{max_updated_at}"
  end

end
