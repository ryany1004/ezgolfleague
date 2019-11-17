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
  const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

  const app = new Vue({
    el: "#tournament-wizard",
    components: {
      datePicker,
      Multiselect,
      VModal
    },
    data: {
      csrfToken: document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
      tournamentWizard: {
        name: null,
        startsAt: null,
        opensAt: null,
        closesAt: null,
        numberOfPlayers: 0,
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
      tournamentWizard: {
        name: {
          required
        },
        startsAt: {
          required
        },
        closesAt: {
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
      },
      canSubmitTournament() {
        if (this.tournamentWizard.scoringRules[0].name != null) {
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

                if (app.tournamentWizard.flights[0].teeBox == null) {
                  app.tournamentWizard.flights[0].teeBox = data[0];
                }
              });
            }
          );
      },
      newFlight(event) {
        var lastFlight = this.tournamentWizard.flights[
          this.tournamentWizard.flights.length - 1
        ];

        let newFlight = new EZGLFlight({
          flightNumber: lastFlight.flightNumber + 1,
          lowHandicap: lastFlight.highHandicap + 1,
          highHandicap: lastFlight.highHandicap + 100
        });

        this.tournamentWizard.flights.push(newFlight);
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
        this.tournamentWizard.scoringRules.forEach(scoringRuleGroup => {
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
          for (var scoringRuleGroupIndex in this.tournamentWizard.scoringRules) {
            var scoringRuleGroup = this.tournamentWizard.scoringRules[scoringRuleGroupIndex];

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
      },
      tournamentData() {
        let payload = {
          name: this.tournamentWizard.name,
          starts_at: this.tournamentWizard.startsAt,
          opens_at: this.tournamentWizard.opensAt,
          closes_at: this.tournamentWizard.closesAt,
          course_id: this.tournamentWizard.course.id,
          number_of_players: this.tournamentWizard.numberOfPlayers,
          flights: [],
          scoring_rules: []
        };

        this.tournamentWizard.flights.forEach(flight => {
          let f = {
            flight_number: flight.flightNumber,
            low_handicap: flight.lowHandicap,
            high_handicap: flight.highHandicap,
            tee_box_id: flight.teeBox.id
          };

          payload.flights.push(f);
        });

        var flatRules = this.tournamentWizard.scoringRules.flat();
        flatRules.forEach(rule => {
          if (rule.canBeSubmitted()) {
            let r = {
              name: rule.name,
              class_name: rule.className,
              hole_configuration: rule.holeConfiguration.value,
              payouts: []
            };

            rule.payouts.forEach(payout => {
              let p = {
                flight_number: payout.flight.flightNumber,
                points: payout.points,
                amount: payout.amount
              }

              r.payouts.push(p);
            });

            payload.scoring_rules.push(r);
          }
        });

        return payload;
      },
      saveTournament() {
        let tournamentPayload = this.tournamentData();
        let jsonPayload = JSON.stringify(tournamentPayload);

        fetch(`/api/v2/leagues/${props.league.id}/tournament_wizard`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': this.csrfToken
          },
          body: jsonPayload
        }).then(function (response) {
          return response.json();
        }).then(function (data) {
          console.log(data);
          // handle errors

          window.location.href = data.url;
        });
      }
    }
  });
});
