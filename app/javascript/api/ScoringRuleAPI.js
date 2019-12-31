import APIClient from './APIClient';

export default {
  createScoringRule(csrfToken, scoringRulePayload) {
    const config = APIClient.formHeader(csrfToken);

    const jsonPayload = JSON.stringify(scoringRulePayload);

    return APIClient.client().post(`/api/v2/leagues/${scoringRulePayload.leagueId}/tournaments/${scoringRulePayload.tournamentId}/tournament_days/${scoringRulePayload.tournamentDayId}/scoring_rules`, jsonPayload, config);
  },
  patchScoringRule(csrfToken, scoringRulePayload) {
    const config = APIClient.formHeader(csrfToken);

    const jsonPayload = JSON.stringify(scoringRulePayload);

    return APIClient.client().patch(`/api/v2/leagues/${scoringRulePayload.leagueId}/tournaments/${scoringRulePayload.tournamentId}/tournament_days/${scoringRulePayload.tournamentDayId}/scoring_rules/${scoringRulePayload.id}.json`, jsonPayload, config);
  },
  destroyScoringRule(csrfToken, scoringRulePayload) {
    const config = APIClient.formHeader(csrfToken);

    return APIClient.client().delete(`/api/v2/leagues/${scoringRulePayload.leagueId}/tournaments/${scoringRulePayload.tournamentId}/tournament_days/${scoringRulePayload.tournamentDayId}/scoring_rules/${scoringRulePayload.id}.json`, config);
  },
};
