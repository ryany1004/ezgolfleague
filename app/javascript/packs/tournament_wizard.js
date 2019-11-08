/* eslint no-console:0 */

import Vue from 'vue/dist/vue.esm.js';

import datePicker from 'vue-bootstrap-datetimepicker';
import 'pc-bootstrap4-datetimepicker/build/css/bootstrap-datetimepicker.css';

import Selectize from 'vue2-selectize'

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    el: '#tournament-wizard',
    components: {
      datePicker,
      Selectize
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
          [null, null], [null, null], [null, null], [null, null]
        ]
      },
      courseTeeBoxes: [],
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
              error: function() {
                console.log('Error fetching course tee boxes')
              },
              success: function(res) {
                app.courseTeeBoxes = res;
              }
          });
        }
      },
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
      }
    }
  });
})