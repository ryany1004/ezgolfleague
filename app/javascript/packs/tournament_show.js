import Vue from 'vue/dist/vue.esm';

import VModal from 'vue-js-modal';

import { BSpinner } from 'bootstrap-vue';

import api from 'api';

import Scorecard from '../components/Scorecard/Scorecard';
import TeeTimeEditor from '../components/TeeTimes/TeeTimeEditor.vue';

Vue.component('b-spinner', BSpinner);
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
        app.$modal.show('scorecard-loading-modal');

        api.getScorecard(event.currentTarget.dataset.scorecardId)
          .then((response) => {
            app.$modal.hide('scorecard-loading-modal');
            app.$modal.show('scorecard-modal', { scorecard: response.data });
          });
      },
    },
  });
});
