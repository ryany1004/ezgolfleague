import Vue from 'vue/dist/vue.esm';
import Vuex from 'vuex';

import * as tournament from './modules/tournament';

Vue.use(Vuex);

export default new Vuex.Store({
  modules: {
    tournament,
  },
  state: {
    csrfToken: null,
  },
  mutations: {
    SET_CSRF_TOKEN(state, token) {
      state.csrfToken = token;
    },
  },
  actions: {
    setCsrfToken({ commit }, { csrfToken }) {
      commit('SET_CSRF_TOKEN', csrfToken);
    },
  },
});
