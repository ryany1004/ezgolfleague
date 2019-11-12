/* eslint no-console:0 */

import Vue from "vue/dist/vue.esm.js";

import datePicker from "vue-bootstrap-datetimepicker";
import "pc-bootstrap4-datetimepicker/build/css/bootstrap-datetimepicker.css";

import Selectize from "vue2-selectize";
import VModal from "vue-js-modal";
import Multiselect from "vue-multiselect";

import Vuelidate from 'vuelidate'
import { required } from 'vuelidate/lib/validators'

Vue.use(VModal, { componentName: "vue-modal" });
Vue.component("multiselect", Multiselect);
Vue.use(Vuelidate)

document.addEventListener("DOMContentLoaded", () => {
  const anchorElement = document.getElementById("tournament-wizard");
  const props = JSON.parse(anchorElement.getAttribute("data"));

  const app = new Vue({
    el: "#tournament-wizard",
    components: {
      datePicker,
      Selectize,
      Multiselect,
      VModal
    },
    data: {
      tournament_wizard: {
        tournament_name: null,
        tournament_starts_at: null,
        tournament_opens_at: null,
        tournament_closes_at: null,
        course_id: null,
        flights: [
          {
            flight_number: 1,
            low_handicap: 0,
            high_handicap: 300,
            tee_box_id: null
          }
        ],
        scoringRules: [
          [{ id: 0 }, { id: 1 }],
          [{ id: 2 }, { id: 3 }],
          [{ id: 4 }, { id: 5 }],
          [{ id: 6 }, { id: 7 }]
        ]
      },
      steps: {
        nameStepSubmitted: false,
        flightsStepSubmitted: false,
        scoringRulesStepSubmitted: false
      },
      showFlights: false,
      courseTeeBoxes: [],
      scoringRules: [],
      selectedScoringRule: "",
      selectedScoringRuleHolesOptions: [
        { name: "Front 9", value: "front_nine" },
        { name: "Back 9", value: "back_nine" },
        { name: "All 18", value: "all_holes" },
        { name: "Custom", value: "custom" }
      ],
      courseSelectSettings: {
        valueField: "id",
        labelField: "name",
        searchField: "name",
        maxItems: "1",
        placeholder: "Start typing to search for a course by name or location",
        create: false,
        render: {
          option: function(item, escape) {
            return (
              "<div>" +
              escape(item.name) +
              " - " +
              escape(item.city) +
              ", " +
              escape(item.us_state) +
              "</div>"
            );
          }
        },
        load: function(query, callback) {
          if (!query.length) return callback();
          $.ajax({
            url: "/api/v2/courses.json?search=" + encodeURIComponent(query),
            type: "GET",
            success: function(res) {
              callback(res);
            },
            error: function() {
              callback();
            }
          });
        },
        onChange: function(value) {
          app.tournament_wizard.course_id = value;

          $.ajax({
            url: `/api/v2/courses/${value}/course_tee_boxes.json`,
            type: "GET",
            success: function(res) {
              app.courseTeeBoxes = res;
            },
            error: function(error) {
              console.log("Error fetching course tee boxes: " + error);
            }
          });
        }
      }
    },
    validations: {
      tournament_wizard: {
        tournament_name: {
          required
        },
        tournament_starts_at: {
          required
        },
        tournament_closes_at: {
          required
        },
        course_id: {
          required
        }
      }
    },
    created: function() {},
    mounted: function() {
      $.ajax({
        url: `/api/v2/leagues/${props.league.id}/scoring_rules.json`,
        method: "GET",
        success: function(data) {
          app.scoringRules = data.flat(1);
        },
        error: function(error) {
          console.log(error);
        }
      });
    },
    methods: {
      newFlight(event) {
        var lastFlight = this.tournament_wizard.flights[
          this.tournament_wizard.flights.length - 1
        ];

        var newFlight = {
          flight_number: lastFlight.flight_number + 1,
          low_handicap: lastFlight.high_handicap + 1,
          high_handicap: lastFlight.high_handicap + 100,
          tee_box_id: null
        };

        this.tournament_wizard.flights.push(newFlight);
      },
      toggleFlights(event) {
        $(".step-2-dot").toggleClass("hidden");
      },
      showGameTypeModal(scoringRule) {
        this.selectedScoringRuleID = scoringRule.id;

        this.$modal.show("scoring-rule");
      },
      hideGameTypeModal() {
        this.selectedScoringRule = {};

        this.$modal.hide("scoring-rule");
      },
      scoringRuleSelected(event) {
        this.selectedScoringRule.custom_holes = [];
      },
      addCurrentScoringRule() {
        this.tournament_wizard.scoringRules.forEach(scoringRuleGroup => {
          scoringRuleGroup.forEach(scoringRule => {
            if (scoringRule.id === this.selectedScoringRuleID) {
              var index = scoringRuleGroup.indexOf(scoringRule);
              scoringRuleGroup[index] = this.selectedScoringRule;
            }
          });
        });

        this.hideGameTypeModal();
      },
      nextStage() {
        if (this.showFlights) {
          stepper1.next();
        } else {
          stepper1.to(3);
        }
      },
      lastStage() {
        if (this.showFlights) {
          stepper1.previous();
        } else {
          stepper1.to(1);
        }
      }
    }
  });
});
