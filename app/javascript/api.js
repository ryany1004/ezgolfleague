import applyConverters from 'axios-case-converter';
import axios from 'axios';

const client = applyConverters(axios.create());

client.defaults.headers.post['Content-Type'] = 'application/json';

export default {
  getGameTypes(leagueId) {
    return client.get(`/api/v2/leagues/${leagueId}/scoring_rules.json`);
  },
  getTournametGroups(leagueId, tournamentId, tournamentDayId) {
    return client.get(`/api/v2/leagues/${leagueId}/tournaments/${tournamentId}/tournament_days/${tournamentDayId}/tournament_groups.json`);
  },
  getScorecard(scorecardId) {
    return client.get(`/api/v2/scorecards/${scorecardId}.json`);
  },
  postTournamentWizard(csrfToken, leagueId, wizardData) {
    const config = {
      headers: {
        'X-CSRF-TOKEN': csrfToken,
      },
    };

    return client.post(`/api/v2/leagues/${leagueId}/tournament_wizard`, wizardData, config);
  },
  patchTournamentGroup(csrfToken, tournamentGroupPayload) {
    const config = {
      headers: {
        'X-CSRF-TOKEN': csrfToken,
      },
    };

    const jsonPayload = JSON.stringify(tournamentGroupPayload);

    return client.patch(`/api/v2/leagues/${tournamentGroupPayload.leagueId}/tournaments/${tournamentGroupPayload.tournamentId}/tournament_days/${tournamentGroupPayload.tournamentDayId}/tournament_groups/${tournamentGroupPayload.group.id}`, jsonPayload, config);
  },
};
