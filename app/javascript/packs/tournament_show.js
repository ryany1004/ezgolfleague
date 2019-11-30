import Vue from "vue/dist/vue.esm.js";
import VModal from 'vue-js-modal';

import api from 'api';

import Scorecard from '../components/Scorecard/Scorecard';

Vue.use(VModal, { componentName: "vue-modal" });

document.addEventListener("DOMContentLoaded", () => {
  const anchorElement = document.getElementById("tournament-show");
  const props = JSON.parse(anchorElement.getAttribute("data"));
  const csrfToken = document
    .querySelector('meta[name="csrf-token"]')
    .getAttribute("content");

  const app = new Vue({
    el: "#tournament-show",
    components: {
      VModal,
      Scorecard,
    },
    data: {
      csrfToken: document
        .querySelector('meta[name="csrf-token"]')
        .getAttribute("content"),
      teeTime: {},
    },
    validations: {},
    created: {},
    mounted: {},
    computed: {},
    methods: {
      showTeeTimeEditorModal(addId) {
        this.$modal.show("tee-time-editor");
        const clickLink = "#grp-" + addId;

        setTimeout(function() {
          document
            .getElementById("listScrollLink")
            .setAttribute("href", clickLink);
          document.getElementById("listScrollLink").click();
        }, 100);
      },
      displayScorecard(event) {
        api.getScorecard(event.currentTarget.dataset.scorecardId)
          .then((response) => {
            app.$modal.show('scorecard-modal', { scorecard: response.data });
          });
      },
    },
  });
});
