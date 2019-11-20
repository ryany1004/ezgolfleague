import Vue from "vue/dist/vue.esm.js";
import VModal from "vue-js-modal";

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
      VModal
    },
    data: {
      csrfToken: document
        .querySelector('meta[name="csrf-token"]')
        .getAttribute("content"),
      teeTime: {}
    },
    validations: {},
    created: {},
    mounted: {},
    computed: {},
    methods: {
      showTeeTimeEditorModal(addId) {
        console.log(addId);
        this.$modal.show("tee-time-editor");

        setTimeout(function() {
          $("#add-players").animate(
            { scrollTop: $(".tee-time-popup." + addId).offset().top - 80 },
            500
          );
        }, 1000);
      },

      openedTeeTimeEditor(e) {
        console.log("opened", e);
        console.log("ref", e.ref);
      }
    }
  });
});

$("#add-players").animate(
  { scrollTop: $(".tee-time-popup.6449").offset().top - 80 },
  500
);
