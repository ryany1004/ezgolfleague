/* eslint no-console:0 */

import Vue from 'vue/dist/vue.esm.js';

import datePicker from 'vue-bootstrap-datetimepicker';
import 'pc-bootstrap4-datetimepicker/build/css/bootstrap-datetimepicker.css';

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    el: '#tournament-wizard',
    components: {
      datePicker
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
            high_handicap: 300
          }
        ]
      }
    },
    methods: {
      newFlight: function (event) {
        var lastFlight = this.tournament_wizard.flights[this.tournament_wizard.flights.length - 1];

        var newFlight = {
          flight_number: lastFlight.flight_number + 1,
          low_handicap: lastFlight.high_handicap + 1,
          high_handicap: lastFlight.high_handicap + 100
        };

        this.tournament_wizard.flights.push(newFlight);
      }
    }
  });
})