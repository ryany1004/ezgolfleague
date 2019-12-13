import Vue from 'vue/dist/vue.esm';

import VModal from 'vue-js-modal';

import NProgress from 'nprogress';
import 'nprogress/nprogress.css';

import api from 'api';

import Scorecard from '../components/Scorecard/Scorecard';
import TeeTimeEditor from '../components/TeeTimes/TeeTimeEditor.vue';
import TournamentDetails from '../components/Tournament/TournamentDetails.vue';

Vue.use(VModal, { componentName: 'vue-modal' });

document.addEventListener('DOMContentLoaded', () => {
  const anchorElement = document.getElementById('tournament-show');
  const props = JSON.parse(anchorElement.getAttribute('data'));

  const app = new Vue({
    el: '#tournament-show',
    components: {
      VModal,
      Scorecard,
      TeeTimeEditor,
      TournamentDetails,
    },
    data: {
      csrfToken: document
        .querySelector('meta[name="csrf-token"]')
        .getAttribute('content'),
      externalData: JSON.parse(anchorElement.getAttribute('data')),
    },
    methods: {
      showTournamentDetails() {
        const tournament = {
          leagueId: this.externalData.league.id,
          tournamentId: this.externalData.tournament.id,
          tournamentDayId: this.externalData.tournament_day.id,
          name: this.externalData.tournament.name,
          startsAt: this.externalData.tournament.tournament_starts_at,
          opensAt: this.externalData.tournament.signup_opens_at,
          closesAt: this.externalData.tournament.signup_closes_at,
          numberOfPlayers: this.externalData.tournament.max_players,
          showTeeTimes: this.externalData.tournament.show_players_tee_times,
        };

        app.$modal.show('tournament-details-modal', { tournament, csrfToken: this.csrfToken });
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
