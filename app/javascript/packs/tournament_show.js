import Vue from 'vue/dist/vue.esm';

import VModal from 'vue-js-modal';

import NProgress from 'nprogress';
import 'nprogress/nprogress.css';

import api from 'api';

import Scorecard from '../components/Scorecard/Scorecard';
import TeeTimeEditor from '../components/TeeTimes/TeeTimeEditor.vue';

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
    },
    data: {
      csrfToken: document
        .querySelector('meta[name="csrf-token"]')
        .getAttribute('content'),
    },
    methods: {
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
