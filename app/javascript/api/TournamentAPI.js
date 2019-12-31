import APIClient from './APIClient';

export default {
  postTournamentWizard(csrfToken, leagueId, wizardData) {
    const config = APIClient.formHeader(csrfToken);

    return APIClient.client().post(`/api/v2/leagues/${leagueId}/tournament_wizard`, wizardData, config);
  },
  getTournament(leagueId, tournamentId) {
    return APIClient.client().get(`/api/v2/leagues/${leagueId}/tournaments/${tournamentId}.json`);
  },
  patchTournamentDetails(csrfToken, tournamentDetailsPayload) {
    const config = APIClient.formHeader(csrfToken);
    const jsonPayload = JSON.stringify(tournamentDetailsPayload);

    return APIClient.client().patch(`/api/v2/leagues/${tournamentDetailsPayload.leagueId}/tournaments/${tournamentDetailsPayload.id}`, jsonPayload, config);
  },
};
