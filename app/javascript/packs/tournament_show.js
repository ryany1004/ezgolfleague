import Vue from 'vue/dist/vue.esm';

import VModal from 'vue-js-modal';

import NProgress from 'nprogress';
import 'nprogress/nprogress.css';

import api from 'api';
import store from '../store/store';

import Scorecard from '../components/Scorecard/Scorecard';
import TeeTimeEditor from '../components/TeeTimes/TeeTimeEditor.vue';
import TournamentDetails from '../components/Tournament/TournamentDetails.vue';
import GolferDetails from '../components/Tournament/GolferDetails.vue';
import Flights from '../components/Tournament/Flights.vue';
import ScoringRules from '../components/Tournament/ScoringRules.vue';

Vue.use(VModal, { componentName: 'vue-modal' });

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
      GolferDetails,
      Flights,
      ScoringRules,
    },
    created() {
      store.dispatch('setCsrfToken', {
        csrfToken: document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute('content'),
      });

      store.dispatch('tournament/fetchTournament', {
        leagueId: props.league.id,
        tournamentId: props.tournament.id,
      });

      store.dispatch('tournament/fetchScoringRules', { leagueId: props.league.id });
    },
    methods: {
      showTournamentDetails() {
        app.$modal.show('tournament-details-modal');
      },
      showGolferDetails(event) {
        NProgress.start();

        const { golferId } = event.currentTarget.dataset;

        api.getGolferDetails(props.league.id, props.tournament.id, props.tournament_day.id, golferId)
          .then((response) => {
            NProgress.done();

            const payload = response.data;
            payload.scoringRules = this.$store.getters['tournament/selectedScoringRules'];

            app.$modal.show('golfer-details-modal', { payload });
          });
      },
      showFlights() {
        app.$modal.show('flights-modal');
      },
      showScoringRules() {
        app.$modal.show('scoring-rules-modal');
      },
      showTeeTimeEditor() {
        api.getTournametGroups(props.league.id, props.tournament.id, props.tournament_day.id)
          .then((response) => {
            app.$modal.show('tee-time-editor', { teeGroupData: response.data });
          });
      },
      showScorecard(event) {
        NProgress.start();

        const { scorecardId } = event.currentTarget.dataset;

        api.getScorecard(scorecardId)
          .then((response) => {
            NProgress.done();

            app.$modal.show('scorecard-modal', { scorecard: response.data });
          });
      },
    },
  });
});
