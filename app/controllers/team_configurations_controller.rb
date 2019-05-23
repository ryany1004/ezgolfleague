class TeamConfigurationsController < BaseController
  before_action :fetch_tournament

  def update
    Tournament.transaction do
      ordered_users = []
      @tournament_day.league_season_team_tournament_day_matchups.each do |matchup|
        next if matchup.teams.count.zero?

        matchup.pairings_by_handicap.each do |pairing|
          pairing.each do |user|
            ordered_users << user
          end
        end
      end

      group_slots = []
      @tournament_day.tournament_groups.each do |group|
        group.max_number_of_players.times do
          group_slots << group
        end
      end

      ordered_users.each_with_index do |user, i|
        if group_slots.count > i
          slot = group_slots[i]

          existing_outing = existing_outing_for_user(user)
          if existing_outing.present?
            existing_outing.update(tournament_group: slot)
          else
            @tournament_day.add_player_to_group(tournament_group: slot, user: user)
          end
        end
      end

      @tournament_day.golf_outings.each do |o|
        o.destroy unless ordered_users.include? o.user
      end
    end

    redirect_to league_tournament_day_players_path(@league, @tournament, @tournament_day)
  end

  def existing_outing_for_user(user)
    # filtered_outings = @existing_outings.select { |outing| outing.user == user }
    # filtered_outings.count.positive? ? filtered_outings.first : nil

    filtered_outings = @tournament_day.golf_outings.select { |outing| outing.user == user }
    filtered_outings.count.positive? ? filtered_outings.first : nil
  end

  def fetch_tournament
    @league = league_from_user_for_league_id(params[:league_id])
    @tournament = fetch_tournament_from_user_for_tournament_id(params[:tournament_id])
    @tournament_day = @tournament.tournament_days.find(params[:tournament_day_id])
  end
end
