import applyConverters from 'axios-case-converter';
import axios from 'axios';

const client = applyConverters(axios.create());

client.defaults.headers.post['Content-Type'] = 'application/json';

// TODO: split this into multiple files / services

export default {
  runAll(requests) {
    return Promise.all(requests);
  },
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
  getTournament(leagueId, tournamentId) {
    return client.get(`/api/v2/leagues/${leagueId}/tournaments/${tournamentId}.json`);
  },
  patchTournamentDetails(csrfToken, tournamentDetailsPayload) {
    const config = {
      headers: {
        'X-CSRF-TOKEN': csrfToken,
      },
    };

    const jsonPayload = JSON.stringify(tournamentDetailsPayload);

    return client.patch(`/api/v2/leagues/${tournamentDetailsPayload.leagueId}/tournaments/${tournamentDetailsPayload.id}`, jsonPayload, config);
  },
  createFlight(csrfToken, flightsPayload) {
    const config = {
      headers: {
        'X-CSRF-TOKEN': csrfToken,
      },
    };

    const jsonPayload = JSON.stringify(flightsPayload);

    return client.post(`/api/v2/leagues/${flightsPayload.leagueId}/tournaments/${flightsPayload.tournamentId}/tournament_days/${flightsPayload.tournamentDayId}/flights`, jsonPayload, config);
  },
  patchFlight(csrfToken, flightsPayload) {
    const config = {
      headers: {
        'X-CSRF-TOKEN': csrfToken,
      },
    };

    const jsonPayload = JSON.stringify(flightsPayload);

    return client.patch(`/api/v2/leagues/${flightsPayload.leagueId}/tournaments/${flightsPayload.tournamentId}/tournament_days/${flightsPayload.tournamentDayId}/flights/${flightsPayload.id}`, jsonPayload, config);
  },
  destroyFlight(csrfToken, flightsPayload) {
    const config = {
      headers: {
        'X-CSRF-TOKEN': csrfToken,
      },
    };

    return client.delete(`/api/v2/leagues/${flightsPayload.leagueId}/tournaments/${flightsPayload.tournamentId}/tournament_days/${flightsPayload.tournamentDayId}/flights/${flightsPayload.id}`, config);
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
  createScoringRule(csrfToken, scoringRulePayload) {
    const config = {
      headers: {
        'X-CSRF-TOKEN': csrfToken,
      },
    };

    const jsonPayload = JSON.stringify(scoringRulePayload);

    return client.post(`/api/v2/leagues/${scoringRulePayload.leagueId}/tournaments/${scoringRulePayload.tournamentId}/tournament_days/${scoringRulePayload.tournamentDayId}/scoring_rules`, jsonPayload, config);
  },
  patchScoringRule(csrfToken, scoringRulePayload) {
    const config = {
      headers: {
        'X-CSRF-TOKEN': csrfToken,
      },
    };

    const jsonPayload = JSON.stringify(scoringRulePayload);

    return client.patch(`/api/v2/leagues/${scoringRulePayload.leagueId}/tournaments/${scoringRulePayload.tournamentId}/tournament_days/${scoringRulePayload.tournamentDayId}/scoring_rules/${scoringRulePayload.id}.json`, jsonPayload, config);
  },
  destroyScoringRule(csrfToken, scoringRulePayload) {
    const config = {
      headers: {
        'X-CSRF-TOKEN': csrfToken,
      },
    };

    return client.delete(`/api/v2/leagues/${scoringRulePayload.leagueId}/tournaments/${scoringRulePayload.tournamentId}/tournament_days/${scoringRulePayload.tournamentDayId}/scoring_rules/${scoringRulePayload.id}.json`, config);
  },
};
