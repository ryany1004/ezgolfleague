module Updaters
  class TournamentGroupTeamUpdater
    def update_for_params(tournament_day, matchup, params)
      team_info = params[:team_submit][:team_id]
      teams_signed_up = self.team_signup(tournament_day, matchup, team_info) if team_info.present?

      teams_signed_up
    end

    def team_signup(tournament_day, matchup, team_info)
      teams_signed_up = []

      team_info.keys.each do |slot_id|
        team = LeagueSeasonTeam.where(id: team_info[slot_id]).first

        if team.present?
          tournament_day.add_league_season_team(team, matchup, slot_id)

          teams_signed_up << team
        end
      end

      teams_signed_up
    end
  end
end
