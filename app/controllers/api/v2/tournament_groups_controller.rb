class Api::V2::TournamentGroupsController < BaseController
  respond_to :json

  before_action :fetch

  def index
    index_payload
  end

  def create
    starting_index = params[:position].to_i
    starting_index = 0 if starting_index.blank?

    basis_group = @tournament_day.tournament_groups[starting_index]

    TournamentGroup.create(tournament_day: @tournament_day,
                           tee_time_at: basis_group.tee_time_at - 8.minutes,
                           max_number_of_players: basis_group.max_number_of_players)

    index_payload

    render :index
  end

  def update
    payload = ActiveSupport::JSON.decode(request.body.read)
    players_payload = payload['group']['players']

    @errors = []

    @tournament_group = @tournament_day.tournament_groups.find(params[:id])
    update_membership(@tournament_group, players_payload.map{|x| x['id']})

    render json: { errors: @errors }
  end

  def destroy
    group_id = params['id']

    @tournament_day.tournament_groups.find(group_id).destroy

    index_payload
    
    render :index
  end

  private

  def index_payload
    @tournament_groups = @tournament_day.tournament_groups

    registered_players = @tournament.players_for_day(@tournament.first_day)
    @non_registered_players = @tournament.league.users.reject { |x| registered_players.include?(x) }
  end

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
