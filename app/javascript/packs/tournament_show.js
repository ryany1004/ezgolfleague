import Vue from 'vue/dist/vue.esm';

import VModal from 'vue-js-modal';

import NProgress from 'nprogress';
import 'nprogress/nprogress.css';

import api from 'api';
import store from '../store/store';

import Scorecard from '../components/Scorecard/Scorecard';
import TeeTimeEditor from '../components/TeeTimes/TeeTimeEditor.vue';
import TournamentDetails from '../components/Tournament/TournamentDetails.vue';
import Flights from '../components/Tournament/Flights.vue';

Vue.use(VModal, { componentName: 'vue-modal' });

function getTournament(leagueId, tournamentId) {
  store.dispatch('tournament/fetchTournament', {
    leagueId,
    tournamentId,
  });
}

Vue.config.productionTip = false;

document.addEventListener('DOMContentLoaded', () => {
  const anchorElement = document.getElementById('tournament-show');
  const props = JSON.parse(anchorElement.getAttribute('data'));

  const app = new Vue({
    el: '#tournament-show',
    store,
    components: {
      VModal,
      Scorecard,
      TeeTimeEditor,
      TournamentDetails,
      Flights,
    },
    created() {
      store.dispatch('setCsrfToken', {
        csrfToken: document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute('content'),
      });

      getTournament(props.league.id, props.tournament.id);
    },
    methods: {
      showTournamentDetails() {
        app.$modal.show('tournament-details-modal');
      },
      showFlights() {
        app.$modal.show('flights-modal');
      },
      showTeeTimeEditor() {
        api.getTournametGroups(props.league.id, props.tournament.id, props.tournament_day.id)
          .then((response) => {
            app.$modal.show('tee-time-editor', { teeGroupData: response.data });
          });
      },
      displayScorecard(event) {
        NProgress.start();

        api.getScorecard(event.currentTarget.dataset.scorecardId)
          .then((response) => {
            NProgress.done();

            app.$modal.show('scorecard-modal', { scorecard: response.data });
          });
      },
    },
  });
});
