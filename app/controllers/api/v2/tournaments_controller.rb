class Api::V2::TournamentsController < BaseController
  respond_to :json

  before_action :fetch

  def show; end

  def update
    payload = ActiveSupport::JSON.decode(request.body.read)

    @errors = []

    starts_at = parse_date(payload['startsAt'])
    registration_opens_at = parse_date(payload['opensAt'])
    registration_closes_at = parse_date(payload['closesAt'])

    @tournament.update(name: payload['name'],
                       signup_opens_at: registration_opens_at,
                       signup_closes_at: registration_closes_at,
                       max_players: payload['numberOfPlayers'],
                       show_players_tee_times: payload['showTeeTimes'])
    @errors << @tournament.errors

    @tournament_day.update(tournament_at: starts_at)
    @errors << @tournament_day.errors

    render json: { errors: @errors, url: league_tournament_path(@tournament.league, @tournament) }
  end

  private

  def parse_date(date_string)
    Date.strptime(date_string, '%m/%d/%Y %I:%M %p')
  end

  def fetch
    @tournament = fetch_tournament_from_user_for_tournament_id(params[:id])
    @tournament_day = @tournament.first_day
  end
end
