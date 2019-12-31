import APIClient from './APIClient';

export default {
  createFlight(csrfToken, flightsPayload) {
    const config = APIClient.formHeader(csrfToken);
    const jsonPayload = JSON.stringify(flightsPayload);

    return APIClient.client().post(`/api/v2/leagues/${flightsPayload.leagueId}/tournaments/${flightsPayload.tournamentId}/tournament_days/${flightsPayload.tournamentDayId}/flights`, jsonPayload, config);
  },
  patchFlight(csrfToken, flightsPayload) {
    const config = APIClient.formHeader(csrfToken);
    const jsonPayload = JSON.stringify(flightsPayload);

    return APIClient.client().patch(`/api/v2/leagues/${flightsPayload.leagueId}/tournaments/${flightsPayload.tournamentId}/tournament_days/${flightsPayload.tournamentDayId}/flights/${flightsPayload.id}`, jsonPayload, config);
  },
  destroyFlight(csrfToken, flightsPayload) {
    const config = APIClient.formHeader(csrfToken);

    return APIClient.client().delete(`/api/v2/leagues/${flightsPayload.leagueId}/tournaments/${flightsPayload.tournamentId}/tournament_days/${flightsPayload.tournamentDayId}/flights/${flightsPayload.id}`, config);
  },
};
