class TeamConfigurationsController < BaseController
  before_action :fetch_tournament

  def update
    # un-tether all outings
    @existing_outings = @tournament_day.golf_outings
    @existing_outings.each do |g|
      g.update(tournament_group: nil)
    end

    @tournament_day.reload

    # add the pairings to the tee groups
    @tournament_day.league_season_team_tournament_day_matchups.each do |matchup|
      next if matchup.teams.count.zero?

      matchup.pairings_by_handicap.each do |pairing|
        group = @tournament_day.tournament_group_with_open_slots(pairing.count)
        raise 'No groups available' if group.blank?

        pairing.each do |user|
          existing_outing = existing_outing_for_user(user)
          if existing_outing.present?
            existing_outing.update(tournament_group: group)
          else
            @tournament_day.add_player_to_group(tournament_group: group, user: user)
          end
        end
      end
    end

    # clean up any still needed
    @existing_outings.each do |o|
      o.destroy if o.tournament_group.blank?
    end

    redirect_to league_tournament_day_players_path(@league, @tournament, @tournament_day)
  end

  def existing_outing_for_user(user)
    filtered_outings = @existing_outings.select { |outing| outing.user == user }
    filtered_outings.count.positive? ? filtered_outings.first : nil
  end

  def fetch_tournament
    @league = league_from_user_for_league_id(params[:league_id])
    @tournament = fetch_tournament_from_user_for_tournament_id(params[:tournament_id])
    @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
  end
end
