import Vue from 'vue/dist/vue.esm';

import datePicker from 'vue-bootstrap-datetimepicker';
import Stepper from 'bs-stepper';

import VModal from 'vue-js-modal';
import Multiselect from 'vue-multiselect';

import Vuelidate from 'vuelidate';
import { required, minValue } from 'vuelidate/lib/validators';

import { ToggleButton } from 'vue-js-toggle-button';

import IndividualStrokePlaySetup from '../components/ScoringRuleSetup/IndividualStrokePlaySetup';

import EZGLFlight from './models/flight';
import EZGLScoringRule from './models/scoring_rule';

Vue.use(VModal, { componentName: 'vue-modal' });
Vue.component('ToggleButton', ToggleButton);
Vue.use(Vuelidate);
Vue.component('multiselect', Multiselect);

Vue.component('stroke-play-setup', IndividualStrokePlaySetup);

document.addEventListener('DOMContentLoaded', () => {
  const bsStepper = new Stepper(document.querySelector('#stepper1'));
  const anchorElement = document.getElementById('tournament-wizard');
  const props = JSON.parse(anchorElement.getAttribute('data'));

  const app = new Vue({
    el: '#tournament-wizard',
    components: {
      datePicker,
      Multiselect,
      VModal,
      IndividualStrokePlaySetup,
    },
    data: {
      csrfToken: document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
      tournamentWizard: {
        name: null,
        startsAt: null,
        opensAt: null,
        closesAt: null,
        showTeeTimes: false,
        enterScoresUntilFinalized: false,
        numberOfPlayers: 0,
        course: null,
        flights: [
          new EZGLFlight({}),
        ],
        scoringRules: [
          [
            new EZGLScoringRule({}),
            new EZGLScoringRule({}),
          ],
          [
            new EZGLScoringRule({}),
            new EZGLScoringRule({}),
          ],
          [
            new EZGLScoringRule({}),
            new EZGLScoringRule({}),
          ],
          [
            new EZGLScoringRule({}),
            new EZGLScoringRule({}),
          ],
        ],
      },
      canSubmit: false,
      isLoading: false,
      filteredCourses: [],
      showBackNineHoles: false,
      showFlights: false,
      courseTeeBoxes: [],
      scoringRules: [],
      selectedScoringRule: {
        customConfiguration: {},
        customHoles: [],
      },
      selectedPayout: {},
      selectedScoringRuleHolesOptions: [],
    },
    validations: {
      tournamentWizard: {
        name: {
          required,
        },
        startsAt: {
          required,
        },
        closesAt: {
          required,
        },
        course: {
          required,
        },
        numberOfPlayers: {
          minValue: minValue(1),
        },
      },
    },
    mounted() {
      fetch(`/api/v2/leagues/${props.league.id}/scoring_rules.json`)
        .then((response) => response.json())
        .then((data) => {
          app.scoringRules = data.flat(1);

          app.scoringRules.forEach((ruleGroup) => {
            ruleGroup.games.forEach((rule) => {
              rule.customConfiguration = {};
            });
          });
        });
    },
    computed: {
      showCustomHolePicker() {
        if (this.selectedScoringRule.hole_configuration != null && this.selectedScoringRule.hole_configuration.value === 'custom') {
          return true;
        }

        return false;
      },
    },
    methods: {
      cancelWizard() {
        window.history.back();
      },
      searchCourses(query) {
        if (query === '') { return; }

        app.isLoading = true;

        fetch(`/api/v2/courses.json?search=${encodeURIComponent(query)}`)
          .then((response) => {
            app.isLoading = false;

            if (response.status < 200 || response.status >= 300) {
              console.log(`Course Load Error: ${response.status}`);

              return;
            }

            response.json().then((data) => {
              const courses = [];

              data.forEach((course) => {
                courses.push({
                  id: course.id,
                  name: `${course.name} in ${course.city}, ${course.us_state}`,
                  number_of_holes: course.number_of_holes,
                });
              });

              app.filteredCourses = courses;
            });
          });
      },
      courseSelected(selectedOption) {
        fetch(`/api/v2/courses/${selectedOption.id}/course_tee_boxes.json`)
          .then((response) => {
            if (response.status < 200 || response.status >= 300) {
              console.log(`Course Tee Box Load Error: ${response.status}`);

              return;
            }

            app.configureHoleOptions(selectedOption.number_of_holes);

            response.json().then((data) => {
              app.courseTeeBoxes = data;

              if (app.tournamentWizard.flights[0].teeBox == null) {
                const flight = app.tournamentWizard.flights[0];
                const firstTeeBox = data[0];

                flight.teeBox = firstTeeBox;
              }
            });
          });
      },
      configureHoleOptions(numberOfHoles) {
        const holeOptions = [];

        if (numberOfHoles >= 9) {
          holeOptions.push({ name: 'Front 9', value: 'front_nine' });
        }

        if (numberOfHoles === 18) {
          holeOptions.push({ name: 'Back 9', value: 'back_nine' });
          holeOptions.push({ name: 'All 18', value: 'all_holes' });

          this.showBackNineHoles = true;
        }

        holeOptions.push({ name: 'Custom', value: 'custom' });

        this.selectedScoringRuleHolesOptions = holeOptions;
      },
      newFlight() {
        const lastFlight = this.tournamentWizard.flights[
          this.tournamentWizard.flights.length - 1
        ];

        const newFlight = new EZGLFlight({
          flightNumber: lastFlight.flightNumber + 1,
          lowHandicap: lastFlight.highHandicap + 1,
          highHandicap: lastFlight.highHandicap + 100,
        });

        this.tournamentWizard.flights.push(newFlight);
      },
      toggleFlights() {
        const element = document.getElementById('step-2-dot');
        element.classList.toggle('hidden');
      },
      showGameTypeModal(scoringRule) {
        this.selectedScoringRuleID = scoringRule.id;

        this.$modal.show('scoring-rule');
      },
      hideGameTypeModal() {
        this.selectedScoringRule = { customHoles: [] };

        this.$modal.hide('scoring-rule');
      },
      newPayout(scoringRule) {
        this.selectedPayout = {
          scoringRule,
          flight: this.tournamentWizard.flights[0],
          points: 0,
          payout: 0,
        };

        this.$modal.show('payouts');
      },
      hidePayoutsModal() {
        this.$modal.hide('payouts');
      },
      savePayout() {
        this.tournamentWizard.scoringRules.forEach((scoringRuleGroup) => {
          scoringRuleGroup.forEach((scoringRule) => {
            if (scoringRule.id === this.selectedPayout.scoringRule.id) {
              scoringRule.payouts.push(this.selectedPayout);
            }
          });
        });

        this.selectedPayout = {};

        this.$modal.hide('payouts');
      },
      scoringRuleSelected() {
        this.selectedScoringRule.custom_holes = [];
        this.selectedScoringRule.customConfiguration = {};
      },
      scoringRuleOptionUpdated(updatedOptions) {
        Object.entries(updatedOptions).forEach((entry) => {
          const key = entry[0];
          const value = entry[1];

          this.selectedScoringRule.customConfiguration[key] = value;
        });
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
                    holeConfiguration: this.selectedScoringRule.hole_configuration,
                    customConfiguration: this.selectedScoringRule.customConfiguration,
                  });

                  this.canSubmit = true;

                  break loop1;
                }
              }
          }

        this.hideGameTypeModal();
      },
      nextStage() {
        const stepperWizard = new Stepper(document.querySelector('#stepper1'));

        if (this.showFlights) {
          stepperWizard.next();
        } else {
          stepperWizard.to(3);
        }
      },
      lastStage() {
        const stepperWizard = new Stepper(document.querySelector('#stepper1'));

        if (this.showFlights) {
          stepperWizard.previous();
        } else {
          stepperWizard.to(1);
        }
      },
      hideErrorModal() {
        this.$modal.hide('save-errors');
      },
      tournamentData() {
        const payload = {
          name: this.tournamentWizard.name,
          starts_at: this.tournamentWizard.startsAt,
          opens_at: this.tournamentWizard.opensAt,
          closes_at: this.tournamentWizard.closesAt,
          course_id: this.tournamentWizard.course.id,
          number_of_players: this.tournamentWizard.numberOfPlayers,
          show_tee_times: this.tournamentWizard.showTeeTimes,
          enter_scores_until_finalized: this.tournamentWizard.enterScoresUntilFinalized,
          flights: [],
          scoring_rules: [],
        };

        this.tournamentWizard.flights.forEach((flight) => {
          const f = {
            flight_number: flight.flightNumber,
            low_handicap: flight.lowHandicap,
            high_handicap: flight.highHandicap,
            tee_box_id: flight.teeBox.id,
          };

          payload.flights.push(f);
        });

        const flatRules = this.tournamentWizard.scoringRules.flat();
        flatRules.forEach((rule) => {
          if (rule.canBeSubmitted()) {
            const r = {
              name: rule.name,
              class_name: rule.className,
              hole_configuration: rule.holeConfiguration.value,
              custom_configuration: rule.customConfiguration,
              payouts: [],
            };

            rule.payouts.forEach((payout) => {
              const p = {
                flight_number: payout.flight.flightNumber,
                points: payout.points ? payout.points : 0,
                amount: payout.amount ? payout.amount : 0,
              };

              r.payouts.push(p);
            });

            payload.scoring_rules.push(r);
          }
        });

        return payload;
      },
      saveTournament() {
        const tournamentPayload = this.tournamentData();
        const jsonPayload = JSON.stringify(tournamentPayload);

        fetch(`/api/v2/leagues/${props.league.id}/tournament_wizard`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': this.csrfToken,
          },
          body: jsonPayload,
        }).then((response) => {
          return response.json();
        }).then((data) => {
          if (data.errors.length > 0) {
            app.$modal.show('save-errors');
          } else {
            window.location.href = data.url;
          }
        });
      },
    },
  });
});
