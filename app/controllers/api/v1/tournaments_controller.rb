class Api::V1::TournamentsController < Api::V1::ApiBaseController
  before_action :protect_with_token, except: [:app_association]

  respond_to :json

  def index
    if @current_user.leagues.blank?
      all_tournaments = []
    else
      cache_key = self.user_tournaments_cache_key
      all_tournaments = Rails.cache.fetch(cache_key, expires_in: 2.minutes, race_condition_ttl: 10) do
        logger.info { "Fetching Tournaments - Not Cached for #{cache_key}" }

        todays_tournaments = Tournament.all_today(@current_user.leagues)
        upcoming_tournaments = Tournament.all_upcoming(@current_user.leagues, nil)
        past_tournaments = Tournament.all_past(@current_user.leagues, nil).limit(8).reorder("tournament_starts_at DESC")

        all_tournaments = todays_tournaments + upcoming_tournaments + past_tournaments
        all_tournaments = all_tournaments.select {|t| t.all_days_are_playable? }.to_a #only include tournaments with all playable days
        all_tournaments = all_tournaments.uniq

        all_tournaments
      end
    end

    respond_with(all_tournaments) do |format|
      format.json { render :json => all_tournaments, content_type: 'application/json' }
    end
  end

  def validate_tournaments_exist
    tournament_ids = params[:tournament_ids]
    split_ids = tournament_ids.split(",")

    invalid_ids = ["0"]

    split_ids.each do |split_id|
      invalid_ids << split_id if !Tournament.exists?(split_id) || Tournament.find(split_id).league.membership_for_user(@current_user).blank?
    end

    respond_with(invalid_ids) do |format|
      format.json { render :json => invalid_ids, content_type: 'application/json' }
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
