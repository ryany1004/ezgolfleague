import applyConverters from 'axios-case-converter';
import axios from 'axios';

const client = applyConverters(axios.create());

client.defaults.headers.post['Content-Type'] = 'application/json';

export default {
  getGameTypes(leagueId) {
    return client.get(`/api/v2/leagues/${leagueId}/scoring_rules.json`);
  },
};
