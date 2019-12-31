import APIClient from './APIClient';

export default {
  getScorecard(scorecardId) {
    return APIClient.client().get(`/api/v2/scorecards/${scorecardId}.json`);
  },
  patchScorecard(csrfToken, scorecardPayload) {
    const config = APIClient.formHeader(csrfToken);

    return APIClient.client().patch(`/api/v2/scorecards/${scorecardPayload.primaryScorecardId}.json`, scorecardPayload, config);
  },
};
