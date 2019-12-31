import APIClient from './APIClient';

export default {
  getGameTypes(leagueId) {
    return APIClient.client().get(`/api/v2/leagues/${leagueId}/scoring_rules.json`);
  },
};
