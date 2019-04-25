class TeamConfigurationsController < BaseController
  before_action :fetch_tournament

  def update
    # remove all of the existing users
    @tournament_day.tournament_groups.each do |group|
      group.users.each do |user|
        @tournament_day.remove_player_from_group(tournament_group: group, user: user)
      end
    end

    @tournament_day.reload

    # add the pairings to the tee groups
    @tournament_day.league_season_team_tournament_day_matchups.each do |matchup|
      matchup.pairings_by_handicap.each do |pairing|
        group = @tournament_day.tournament_group_with_open_slots(pairing.count)
        raise 'No groups available' if group.blank?

        pairing.each do |user|
          @tournament_day.add_player_to_group(tournament_group: group, user: user)
        end
      end
    end

    redirect_to league_tournament_day_players_path(@league, @tournament, @tournament_day)
  end

  def fetch_tournament
    @league = league_from_user_for_league_id(params[:league_id])
    @tournament = fetch_tournament_from_user_for_tournament_id(params[:tournament_id])
    @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
  end
end
