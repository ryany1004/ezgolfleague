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
            teeBox: null
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
      isLoading: false,
      filteredCourses: [],
      showFlights: false,
      courseTeeBoxes: [],
      scoringRules: [],
      selectedScoringRule: {
        customHoles: []
      },
      selectedScoringRuleHolesOptions: [
        { name: "Front 9", value: "front_nine" },
        { name: "Back 9", value: "back_nine" },
        { name: "All 18", value: "all_holes" },
        { name: "Custom", value: "custom" }
      ],
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
    computed: {
      showCustomHolePicker() {
        if (this.selectedScoringRule.hole_configuration != null && this.selectedScoringRule.hole_configuration.value == 'custom') {
          return true;
        } else {
          return false;
        }
      }
    },
    methods: {
      searchCourses(query) {
        if (query === "") { return }

        app.isLoading = true;

        fetch(`/api/v2/courses.json?search=${encodeURIComponent(query)}`)
          .then(
            function(response) {
              app.isLoading = false;

              if (response.status < 200 || response.status >= 300) {
                console.log(`Course Load Error: ${response.status}`);

                return;
              }

              response.json().then(function(data) {
                var courses = [];

                data.forEach(course => {
                  courses.push({ id: course.id, name: `${course.name} in ${course.city}, ${course.us_state}` });
                });

                app.filteredCourses = courses;
              });
            }
          );
      },
      courseSelected(selectedOption, id) {
        fetch(`/api/v2/courses/${selectedOption.id}/course_tee_boxes.json`)
          .then(
            function(response) {
              if (response.status < 200 || response.status >= 300) {
                console.log(`Course Tee Box Load Error: ${response.status}`);

                return;
              }

              response.json().then(function(data) {
                app.courseTeeBoxes = data;

                if (app.tournament_wizard.flights[0].teeBox == null) {
                  app.tournament_wizard.flights[0].teeBox = data[0];
                }
              });
            }
          );
      },
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
