import applyConverters from 'axios-case-converter';
import axios from 'axios';

const client = applyConverters(axios.create());

client.defaults.headers.post['Content-Type'] = 'application/json';

export default {
  searchCourses(query) {
    return client.get(`/api/v2/courses.json?search=${encodeURIComponent(query)}`);
  },
  getCourseTeeBoxes(courseId) {
    return client.get(`/api/v2/courses/${courseId}/course_tee_boxes.json`);
  },
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
  patchTournamentDetails(csrfToken, tournamentDetailsPayload) {
    const config = {
      headers: {
        'X-CSRF-TOKEN': csrfToken,
      },
    };

    const jsonPayload = JSON.stringify(tournamentDetailsPayload);

    return client.patch(`/api/v2/leagues/${tournamentDetailsPayload.leagueId}/tournaments/${tournamentDetailsPayload.tournamentId}`, jsonPayload, config);
  },
  createTournamentGroup(csrfToken, tournamentGroupPayload) {
    const config = {
      headers: {
        'X-CSRF-TOKEN': csrfToken,
      },
    };

    return client.post(`/api/v2/leagues/${tournamentGroupPayload.leagueId}/tournaments/${tournamentGroupPayload.tournamentId}/tournament_days/${tournamentGroupPayload.tournamentDayId}/tournament_groups?position=${tournamentGroupPayload.position}`, null, config);
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
  destroyTournamentGroup(csrfToken, tournamentGroupPayload) {
    const config = {
      headers: {
        'X-CSRF-TOKEN': csrfToken,
      },
    };

    return client.delete(`/api/v2/leagues/${tournamentGroupPayload.leagueId}/tournaments/${tournamentGroupPayload.tournamentId}/tournament_days/${tournamentGroupPayload.tournamentDayId}/tournament_groups/${tournamentGroupPayload.group.id}.json`, config);
  },
};
