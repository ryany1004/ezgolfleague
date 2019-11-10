/* eslint no-console:0 */

import Vue from 'vue/dist/vue.esm.js';

import datePicker from 'vue-bootstrap-datetimepicker';
import 'pc-bootstrap4-datetimepicker/build/css/bootstrap-datetimepicker.css';

import Selectize from 'vue2-selectize'
import VModal from 'vue-js-modal'

Vue.use(VModal, { componentName: "vue-modal" })

document.addEventListener('DOMContentLoaded', () => {
  const anchorElement = document.getElementById("tournament-wizard")
  const props = JSON.parse(anchorElement.getAttribute('data'))

  const app = new Vue({
    el: '#tournament-wizard',
    components: {
      datePicker,
      Selectize,
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
          [{ index: 0 }, { index: 1 }], [{ index: 2 }, { index: 3 }], [{ index: 4 }, { index: 5 }], [{ index: 6 }, { index: 7 }]
        ]
      },
      courseTeeBoxes: [],
      scoringRules: [],
      selectedScoringRule: { name: null },
      courseSelectSettings: {
        valueField: 'id',
        labelField: 'name',
        searchField: 'name',
        maxItems: '1',
        placeholder: 'Start typing to search for a course by name or location',
        create: false,
        render: {
             option: function (item, escape) {
                 return '<div>' + escape(item.name) + ' - ' + escape(item.city) + ', ' + escape(item.us_state) + '</div>';
             }
        },
        load: function(query, callback) {
            if (!query.length) return callback();
            $.ajax({
                url: '/api/v2/courses.json?search=' + encodeURIComponent(query),
                type: 'GET',
                error: function() {
                  callback();
                },
                success: function(res) {
                  callback(res);
                }
            });
        },
        onChange: function(value) {
          console.log(value);
          $.ajax({
              url: "/api/v2/courses/" + value + "/course_tee_boxes.json",
              type: 'GET',
              error: function(error) {
                console.log('Error fetching course tee boxes: ' + error);
              },
              success: function(res) {
                app.courseTeeBoxes = res;
              }
          });
        }
      },
    },
    mounted: function() {
      var self = this;

      $.ajax({
        url: `/api/v2/leagues/${props.league.id}/scoring_rules.json`,
        method: 'GET',
        success: function(data) {
          app.scoringRules = data;
        },
        error: function(error) {
          console.log(error);
        }
      })
    },
    methods: {
      newFlight: function (event) {
        var lastFlight = this.tournament_wizard.flights[this.tournament_wizard.flights.length - 1];

        var newFlight = {
          flight_number: lastFlight.flight_number + 1,
          low_handicap: lastFlight.high_handicap + 1,
          high_handicap: lastFlight.high_handicap + 100,
          tee_box_id: null
        };

        this.tournament_wizard.flights.push(newFlight);
      },
      toggleFlights: function(event) {
        $('.step-2-dot').toggleClass("hidden");
      },
      showGameTypeModal (scoringRule) {
        self.selectedScoringRule = scoringRule;

        this.$modal.show('scoring-rule');
      },
      hideGameTypeModal () {
        this.$modal.hide('scoring-rule');
      }
    }
  });
})