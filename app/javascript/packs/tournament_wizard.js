/* eslint no-console:0 */

import Vue from "vue/dist/vue.esm.js";

import datePicker from "vue-bootstrap-datetimepicker";
import "pc-bootstrap4-datetimepicker/build/css/bootstrap-datetimepicker.css";

import VModal from "vue-js-modal";
import Multiselect from "vue-multiselect";

import Vuelidate from 'vuelidate';
import { required } from 'vuelidate/lib/validators';

import EZGLFlight from 'packs/models/flight.js';
import EZGLScoringRule from 'packs/models/scoring_rule.js'
import EZGLPayout from 'packs/models/payout.js'

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
      Multiselect,
      VModal
    },
    data: {
      tournament_wizard: {
        tournament_name: null,
        tournament_starts_at: null,
        tournament_opens_at: null,
        tournament_closes_at: null,
        course: null,
        flights: [
          new EZGLFlight({})
        ],
        scoringRules: [
          [
            new EZGLScoringRule({}),
            new EZGLScoringRule({})
          ],
          [
            new EZGLScoringRule({}),
            new EZGLScoringRule({})
          ],
          [
            new EZGLScoringRule({}),
            new EZGLScoringRule({})
          ],
          [
            new EZGLScoringRule({}),
            new EZGLScoringRule({})
          ]
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
      selectedPayout: {},
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
        course: {
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

        let newFlight = new EZGLFlight({
          flightNumber: lastFlight.flightNumber + 1,
          lowHandicap: lastFlight.highHandicap + 1,
          highHandicap: lastFlight.highHandicap + 100
        });

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
        this.selectedScoringRule = {customHoles: []};

        this.$modal.hide("scoring-rule");
      },
      newPayout(scoringRule) {
        this.selectedPayout = {
          scoringRule: scoringRule
        }

        this.$modal.show("payouts");
      },
      hidePayoutsModal() {
        this.$modal.hide("payouts");
      },
      savePayout() {
        this.tournament_wizard.scoringRules.forEach(scoringRuleGroup => {
          scoringRuleGroup.forEach(scoringRule => {
            if (scoringRule.id === this.selectedPayout.scoringRule.id) {
              scoringRule.payouts.push(this.selectedPayout);
            }
          });
        });

        this.selectedPayout = {};

        this.$modal.hide("payouts");
      },
      scoringRuleSelected(event) {
        this.selectedScoringRule.custom_holes = [];
      },
      addCurrentScoringRule() {
        loop1:
          for (var scoringRuleGroupIndex in this.tournament_wizard.scoringRules) {
            var scoringRuleGroup = this.tournament_wizard.scoringRules[scoringRuleGroupIndex];

            loop2:
              for (var scoringRuleIndex in scoringRuleGroup) {
                var scoringRule = scoringRuleGroup[scoringRuleIndex];

                if (scoringRule.canBeAssigned()) {
                  var index = scoringRuleGroup.indexOf(scoringRule);

                  scoringRuleGroup[index] = new EZGLScoringRule({
                    name: this.selectedScoringRule.name,
                    className: this.selectedScoringRule.class_name,
                    holeConfiguration: this.selectedScoringRule.hole_configuration
                  });

                  break loop1;
                }
              }
          }

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
