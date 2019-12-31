import APIClient from './APIClient';

export default {
  getTournamentGroups(leagueId, tournamentId, tournamentDayId) {
    return APIClient.client().get(`/api/v2/leagues/${leagueId}/tournaments/${tournamentId}/tournament_days/${tournamentDayId}/tournament_groups.json`);
  },
  createTournamentGroup(csrfToken, tournamentGroupPayload) {
    const config = APIClient.formHeader(csrfToken);

    return APIClient.client().post(`/api/v2/leagues/${tournamentGroupPayload.leagueId}/tournaments/${tournamentGroupPayload.tournamentId}/tournament_days/${tournamentGroupPayload.tournamentDayId}/tournament_groups?position=${tournamentGroupPayload.position}`, null, config);
  },
  patchTournamentGroup(csrfToken, tournamentGroupPayload) {
    const config = APIClient.formHeader(csrfToken);

    const jsonPayload = JSON.stringify(tournamentGroupPayload);

    return APIClient.client().patch(`/api/v2/leagues/${tournamentGroupPayload.leagueId}/tournaments/${tournamentGroupPayload.tournamentId}/tournament_days/${tournamentGroupPayload.tournamentDayId}/tournament_groups/${tournamentGroupPayload.group.id}`, jsonPayload, config);
  },
  destroyTournamentGroup(csrfToken, tournamentGroupPayload) {
    const config = APIClient.formHeader(csrfToken);

    return APIClient.client().delete(`/api/v2/leagues/${tournamentGroupPayload.leagueId}/tournaments/${tournamentGroupPayload.tournamentId}/tournament_days/${tournamentGroupPayload.tournamentDayId}/tournament_groups/${tournamentGroupPayload.group.id}.json`, config);
  },
};
