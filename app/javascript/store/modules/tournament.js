import api from '../../api';

export const namespaced = true;

export const state = {
  tournament: {},
};

export const mutations = {
  SET_TOURNAMENT(state, payload) {
    state.tournament = payload;
  },
  UPDATE_TOURNAMENT_VALUE(state, payload) {
    state.tournament[payload.key] = payload.value;
  },
};

export const actions = {
  fetchTournament({ commit }, { leagueId, tournamentId }) {
    return api.getTournament(leagueId, tournamentId)
      .then((response) => {
        commit('SET_TOURNAMENT', response.data);
      });
  },
  saveTournamentDetails({ rootState }) {
    return api.patchTournamentDetails(rootState.csrfToken, state.tournament);
  },
  updateTournamentValue({ commit }, { key, value }) {
    commit('UPDATE_TOURNAMENT_VALUE', { key, value });
  },
};

export const getters = {
  getTournament: (state) => {
    return state.tournament;
  },
};
