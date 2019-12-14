import { getField, updateField } from 'vuex-map-fields';

import api from '../../api';

export const namespaced = true;

export const state = {
  tournament: {
    tournamentDays: [
      {
        course: {},
        flights: [],
        scoringRules: [],
      },
    ],
  },
  flightsToDelete: [],
};

export const mutations = {
  updateField,
  setTournament(state, payload) {
    state.tournament = payload;
  },
  addFlight(state, payload) {
    state.tournament.tournamentDays[0].flights.push(payload);
  },
  deleteFlight(state, index) {
    const deadFlight = state.tournament.tournamentDays[0].flights[index];
    if (deadFlight.id != null) {
      state.flightsToDelete.push(deadFlight);
    }
    
    state.tournament.tournamentDays[0].flights.splice(index, 1);
  },
};

export const actions = {
  fetchTournament({ commit }, { leagueId, tournamentId }) {
    return api.getTournament(leagueId, tournamentId)
      .then((response) => {
        commit('setTournament', response.data);
      });
  },
  saveTournamentDetails({ rootState }) {
    return api.patchTournamentDetails(rootState.csrfToken, state.tournament);
  },
  addFlight({ commit }) {
    const existingFlights = this.state.tournament.tournament.tournamentDays[0].flights;

    const lastFlight = existingFlights[
      existingFlights.length - 1
    ];

    const newFlight = {
      flightNumber: lastFlight.flightNumber + 1,
      lowerBound: lastFlight.upperBound + 1,
      upperBound: lastFlight.upperBound + 100,
      courseTeeBox: lastFlight.courseTeeBox,
    };

    commit('addFlight', newFlight);
  },
  deleteFlight({ commit }, { index }) {
    commit('deleteFlight', index);
  },
  saveFlights({ rootState }) {
    const { flights } = state.tournament.tournamentDays[0];

    const requests = [];

    flights.forEach((flight) => {
      const flightPayload = {
        leagueId: state.tournament.leagueId,
        tournamentId: state.tournament.id,
        tournamentDayId: state.tournament.tournamentDays[0].id,
        flightNumber: flight.flightNumber,
        lowerBound: flight.lowerBound,
        upperBound: flight.upperBound,
        courseTeeBox: {
          id: flight.courseTeeBox.id,
        },
      };

      if (flight.id == null) {
        requests.push(api.createFlight(rootState.csrfToken, flightPayload));
      } else {
        flightPayload.id = flight.id;

        requests.push(api.patchFlight(rootState.csrfToken, flightPayload));
      }
    });

    const deadFlights = state.flightsToDelete;
    deadFlights.forEach((flight) => {
      const flightPayload = {
        leagueId: state.tournament.leagueId,
        tournamentId: state.tournament.id,
        tournamentDayId: state.tournament.tournamentDays[0].id,
        id: flight.id,
      };

      requests.push(api.destroyFlight(rootState.csrfToken, flightPayload));
    });

    return api.runAll(requests);
  },
};

export const getters = {
  getField,
};
