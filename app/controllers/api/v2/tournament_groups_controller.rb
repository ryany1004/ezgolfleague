class Api::V2::TournamentGroupsController < BaseController
  before_action :fetch

  def index
    @tournament_groups = @tournament_day.tournament_groups

    registered_players = @tournament.players_for_day(@tournament.first_day)
    @non_registered_players = @tournament.league.users.reject { |x| registered_players.include?(x) }
  end

  def update
    payload = ActiveSupport::JSON.decode(request.body.read)
    players_payload = payload['group']['players']

    @errors = []

    @tournament_group = @tournament_day.tournament_groups.find(params[:id])
    update_membership(@tournament_group, players_payload.map{|x| x['id']})

    render json: { errors: @errors }
  end

  private

  def update_membership(group, player_ids)
    player_ids.each do |player_id|
      player = User.find(player_id)

      group.add_or_move_user_to_group(player) unless group.users.include?(player)
    end

    player_ids_to_remove = group.users.map(&:id) - player_ids
    player_ids_to_remove.each do |player_id|
      player = User.find(player_id)

      @tournament_day.remove_player_from_group(tournament_group: group, user: player)
    end
  end

  def fetch
    @tournament = fetch_tournament_from_user_for_tournament_id(params[:tournament_id])
    @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
  end
end
