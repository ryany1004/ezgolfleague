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
  holeOptions: [],
  scoringRules: [],
  flightsToDelete: [],
  scoringRulesToDelete: [],
};

export const mutations = {
  updateField,
  setTournament(state, payload) {
    state.tournament = payload;

    const holeOptions = [];
    const { numberOfHoles } = state.tournament.tournamentDays[0].course;

    if (numberOfHoles >= 9) {
      holeOptions.push({ name: 'Front 9', value: 'frontNine' });
    }

    if (numberOfHoles === 18) {
      holeOptions.push({ name: 'Back 9', value: 'backNine' });
      holeOptions.push({ name: 'All 18', value: 'allHoles' });
    }

    holeOptions.push({ name: 'Custom', value: 'custom' });

    state.holeOptions = holeOptions;
  },
  setScoringRules(state, payload) {
    state.scoringRules = payload;
  },
  addFlight(state, payload) {
    state.tournament.tournamentDays[0].flights.push(payload);
  },
  deleteFlight(state, index) {
    const deadFlight = state.tournament.tournamentDays[0].flights[index];
    if (deadFlight.id != undefined) {
      state.flightsToDelete.push(deadFlight);
    }

    state.tournament.tournamentDays[0].flights.splice(index, 1);
  },
  addScoringRule(state, payload) {
    const newRule = {
      name: payload.name,
      setupComponentName: payload.setupComponentName,
      customNameAllowed: payload.customNameAllowed,
      showCourseHoles: payload.showCourseHoles,
      className: payload.className,
      duesAmount: 0,
      isOptIn: false,
      customName: null,
      holeConfiguration: state.holeOptions[0],
      customConfiguration: {},
    };

    state.tournament.tournamentDays[0].scoringRules.push(newRule);
  },
  deleteScoringRule(state, index) {
    const deadRule = state.tournament.tournamentDays[0].scoringRules[index];
    if (deadRule.id != undefined) {
      state.scoringRulesToDelete.push(deadRule);
    }

    state.tournament.tournamentDays[0].scoringRules.splice(index, 1);
  },
  updateCustomScoringRuleConfigurationValue(state, payload) {
    const { scoringRules } = state.tournament.tournamentDays[0];
    const rule = scoringRules[payload.index];

    rule.customConfiguration[payload.attribute] = payload.newValue;
  },
};

export const actions = {
  fetchTournament({ commit }, { leagueId, tournamentId }) {
    return api.getTournament(leagueId, tournamentId)
      .then((response) => {
        commit('setTournament', response.data);
      });
  },
  fetchScoringRules({ commit }, { leagueId }) {
    return api.getGameTypes(leagueId)
      .then((response) => {
        const flattenedRules = response.data.flat(1);

        commit('setScoringRules', flattenedRules);
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
  addScoringRule({ commit }, { value }) {
    commit('addScoringRule', value);
  },
  deleteScoringRule({ commit }, { index }) {
    commit('deleteScoringRule', index);
  },
  updateCustomScoringRuleConfigurationValue({ commit }, { attribute, index, newValue }) {
    commit('updateCustomScoringRuleConfigurationValue', { attribute, index, newValue });
  },
  saveScoringRules({ rootState }) {
    const { scoringRules } = state.tournament.tournamentDays[0];

    const requests = [];

    scoringRules.forEach((rule) => {
      const rulePayload = {
        leagueId: state.tournament.leagueId,
        tournamentId: state.tournament.id,
        tournamentDayId: state.tournament.tournamentDays[0].id,
        customName: rule.customName,
        duesAmount: rule.duesAmount,
        isOptIn: rule.isOptIn,
        holeConfiguration: rule.holeConfiguration,
        className: rule.className,
        customConfiguration: rule.customConfiguration,
      };

      if (rule.id == null) {
        requests.push(api.createScoringRule(rootState.csrfToken, rulePayload));
      } else {
        rulePayload.id = rule.id;

        requests.push(api.patchScoringRule(rootState.csrfToken, rulePayload));
      }
    });

    const deadRules = state.scoringRulesToDelete;
    deadRules.forEach((rule) => {
      const rulePayload = {
        leagueId: state.tournament.leagueId,
        tournamentId: state.tournament.id,
        tournamentDayId: state.tournament.tournamentDays[0].id,
        id: rule.id,
      };

      requests.push(api.destroyScoringRule(rootState.csrfToken, rulePayload));
    });

    return api.runAll(requests);
  },
};

export const getters = {
  getField,
  customScoringRuleConfigurationValue: (state) => (attribute, index) => {
    const { scoringRules } = state.tournament.tournamentDays[0];
    const rule = scoringRules[index];

    return rule.customConfiguration[attribute];
  },
  groupedScoringRules: (state) => {
    return state.scoringRules;
  },
  availableScoringRules: (state) => {
    const rules = [];

    state.scoringRules.forEach((rule) => {
      rule.games.forEach((game) => {
        rules.push(game);
      });
    });

    return rules;
  },
};
