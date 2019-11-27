class Api::V2::TournamentGroupsController < BaseController
  before_action :fetch

  def index
    @tournament_groups = @tournament_day.tournament_groups

    registered_players = @tournament.players_for_day(@tournament.first_day)
    @non_registered_players = @tournament.league.users.reject { |x| registered_players.include?(x) }
  end

  private

  def fetch
    @tournament = fetch_tournament_from_user_for_tournament_id(params[:tournament_id])
    @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
  end
end
