class Api::V2::TournamentsController < BaseController
  respond_to :json

  before_action :fetch

  def update
    payload = ActiveSupport::JSON.decode(request.body.read)

    @errors = []

    starts_at = DateTime.parse(payload['startsAt'])
    registration_opens_at = DateTime.parse(payload['opensAt'])
    registration_closes_at = DateTime.parse(payload['closesAt'])

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

  def fetch
    @tournament = fetch_tournament_from_user_for_tournament_id(params[:id])
    @tournament_day = @tournament.first_day
  end
end
