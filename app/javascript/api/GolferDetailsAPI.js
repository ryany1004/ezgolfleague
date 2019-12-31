import APIClient from './APIClient';

export default {
  getGolferDetails(leagueId, tournamentId, tournamentDayId, golferId) {
    return APIClient.client().get(`/api/v2/leagues/${leagueId}/tournaments/${tournamentId}/tournament_days/${tournamentDayId}/golfer_details/${golferId}.json`);
  },
  patchGolferDetails(csrfToken, leagueId, tournamentId, tournamentDayId, golferId, golferPayload) {
    const config = APIClient.formHeader(csrfToken);
    const jsonPayload = JSON.stringify(golferPayload);

    return APIClient.client().patch(`/api/v2/leagues/${leagueId}/tournaments/${tournamentId}/tournament_days/${tournamentDayId}/golfer_details/${golferId}.json`, jsonPayload, config);
  },
  destroyGolferDetails(csrfToken, leagueId, tournamentId, tournamentDayId, golferId) {
    const config = APIClient.formHeader(csrfToken);

    return APIClient.client().delete(`/api/v2/leagues/${leagueId}/tournaments/${tournamentId}/tournament_days/${tournamentDayId}/golfer_details/${golferId}.json`, config);
  },
};
