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
        this.$modal.show('scoring-rule', { scoringRule: scoringRule, scoringRuleOptions: this.scoringRules });
      },
      hideGameTypeModal () {
        this.$modal.hide('scoring-rule');
      }
    }
  });
})

Vue.component('scoring-rule-modal', {
  props: ['modalIndex', 'scoringRuleOptions', 'scoringRule'],
  components: {
    Selectize
  },
  template: `
    <div class="modal fade" :id="'addGameTypeModal' + modalIndex" tabindex="-1" role="dialog" aria-labelledby="addGameTypeCenterTitle" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
        <div class="modal-content">   
          <div class="modal-body welcome p-5">
            <div class="p-3">
              <h2 style="font-size:30px;">Add Game</h2>
            </div>
            <div class="step-1-content-form step-1-content">
              <div class="row">
                <div class="col-md-3 text-right">
                  <label>Game Type</label>
                </div>
                  <div class="col-md-8">
                    <selectize v-model="scoringRule.name">
                      <option v-for="scoringRuleOption in scoringRuleOptions" v-bind:value="scoringRuleOption.class_name">
                        {{ scoringRuleOption.name }}
                      </option>
                    </selectize>
                </div>
              </div>
            </div>

            <div class="step-1-content-form step-1-content">
              <div class="row">
                <div class="col-md-3 text-right">
                  <label>Payout</label>
                </div>
                <div class="col-md-8 tee-times-inputs">
                  <div>
                    <input label="false" aria-required="true" placeholder="Payout" type="text" class="form-control string required form-control">
                  </div>
                </div>
              </div>
            </div>

            <div class="step-1-content-form step-1-content pt-2">
              <div class="row">
                <div class="col-md-3 text-right">
                  <label>Holes</label>
                </div>
                <div class="col-md-8 tee-times-inputs">
                  <div class="col-md-8 p-0">
                    <select id="holes">
                      <option value="front9">Front 9</option>
                      <option value="back9">Back 9</option>
                      <option value="18">18</option>
                      <option value="custom">Custom</option>
                    </select>
                  </div>
                </div>
              </div>
            </div> 

            <div class="step-1-content-form step-1-content holesCustomOptions hidden">
              <div class="row">
                <div class="col-md-3 text-right">
                  <label>Holes (Custom)</label>
                </div>
                <div class="col-md-8 pl-5">
                  <div class="row pl-5">
                    <div>
                      <input type="checkbox" value="hole1"> Hole 1<br>
                      <input type="checkbox" value="hole2"> Hole 2<br>
                      <input type="checkbox" value="hole3"> Hole 3<br>
                      <input type="checkbox" value="hole4"> Hole 4<br>
                      <input type="checkbox" value="hole5"> Hole 5<br>
                      <input type="checkbox" value="hole6"> Hole 6<br>
                      <input type="checkbox" value="hole7"> Hole 7<br>
                      <input type="checkbox" value="hole8"> Hole 8<br>
                      <input type="checkbox" value="hole9"> Hole 9<br>
                    </div>
                    <div class="pl-5">
                      <input type="checkbox" value="hole10"> Hole 10<br>
                      <input type="checkbox" value="hole11"> Hole 11<br>
                      <input type="checkbox" value="hole12"> Hole 12<br>
                      <input type="checkbox" value="hole13"> Hole 13<br>
                      <input type="checkbox" value="hole14"> Hole 14<br>
                      <input type="checkbox" value="hole15"> Hole 15<br>
                      <input type="checkbox" value="hole16"> Hole 16<br>
                      <input type="checkbox" value="hole17"> Hole 17<br>
                      <input type="checkbox" value="hole18"> Hole 18<br>
                    </div>
                  </div>
                </div>
              </div>
            </div> 
          </div>

          <div class="modal-footer">
            <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
            <button type="button" class="btn__ezgl-secondary" data-dismiss="modal">Save</button>
          </div>
        </div>
      </div>
    </div>
  `
})