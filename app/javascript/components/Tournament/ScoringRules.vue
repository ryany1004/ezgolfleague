<template>
  <vue-modal name="scoring-rules-modal" height="auto" width="85%" :scrollable="true">
    <link rel="stylesheet" href="https://unpkg.com/vue-multiselect@2.1.0/dist/vue-multiselect.min.css">

    <form onSubmit="return false">
      <div class="welcome p-5">
        <div class="p-3">
          <h2 style="font-size:30px;">Game Types</h2>
        </div>

        <div class='row'>
          <div class="col-md-12">
            <div class="btn-group mb-3 float-right">
              <button type="button" class="btn__ezgl-secondary-outline float-right" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                Add Game Type
              </button>
              <div class="dropdown-menu">
                <a class="dropdown-item" href="#" v-for="template in availableScoringRules" v-on:click="newScoringRule(template)" v-bind:key="template.className">{{ template.name }}</a>
              </div>
            </div>
          </div>
        </div>

        <div class='row mb-8' v-for="(scoringRule, scoringRuleIndex) in scoringRules" :key="scoringRuleIndex">
          <div class="col-md-12">
            <div class="card">
              <h5 class="card-header">{{ scoringRule.name }}</h5>
              <div class="card-body">
                <h5 class="card-title">
                  Details
                </h5>
                <table class="table">
                  <tbody>
                    <tr>
                      <td>Dues Amount $</td>
                      <td><input label="false" type="text" class="form-control string required form-control" v-model="scoringRule.duesAmount"></td>
                      <td>&nbsp;</td>
                    </tr>
                    <tr>
                      <td>Optional</td>
                      <td><input label="false" type="checkbox" class="form-control required form-control" v-model="scoringRule.isOptIn"></td>
                      <td>&nbsp;</td>
                    </tr>
                    <tr v-if="showCustomName(scoringRule)">
                      <td>Name</td>
                      <td><input label="false" type="text" class="form-control string required form-control" v-model="scoringRule.customName"></td>
                      <td>&nbsp;</td>
                    </tr>
                    <tr v-if="showCourseHoles(scoringRule)">
                      <td>Holes</td>
                      <td>
                        <select v-model="scoringRule.holeConfiguration">
                          <option v-for="option in holeOptions" v-bind:key="option.value" v-bind:value="{ name: option.name, value: option.value }">
                            {{ option.name }}
                          </option>
                        </select>
                      </td>
                      <td>&nbsp;</td>
                    </tr>
                    <tr v-if="showCustomHoles(scoringRule)">
                      <td>Holes (Custom)</td>
                      <td>
                        <div class="row">
                          <div>
                            <input type="checkbox" value="1" v-model="scoringRule.customHoles"> Hole 1<br>
                            <input type="checkbox" value="2" v-model="scoringRule.customHoles"> Hole 2<br>
                            <input type="checkbox" value="3" v-model="scoringRule.customHoles"> Hole 3<br>
                            <input type="checkbox" value="4" v-model="scoringRule.customHoles"> Hole 4<br>
                            <input type="checkbox" value="5" v-model="scoringRule.customHoles"> Hole 5<br>
                            <input type="checkbox" value="6" v-model="scoringRule.customHoles"> Hole 6<br>
                            <input type="checkbox" value="7" v-model="scoringRule.customHoles"> Hole 7<br>
                            <input type="checkbox" value="8" v-model="scoringRule.customHoles"> Hole 8<br>
                            <input type="checkbox" value="9" v-model="scoringRule.customHoles"> Hole 9<br>
                          </div>
                          <div class="pl-5" v-if="showBackNine">
                            <input type="checkbox" value="10" v-model="scoringRule.customHoles"> Hole 10<br>
                            <input type="checkbox" value="11" v-model="scoringRule.customHoles"> Hole 11<br>
                            <input type="checkbox" value="12" v-model="scoringRule.customHoles"> Hole 12<br>
                            <input type="checkbox" value="13" v-model="scoringRule.customHoles"> Hole 13<br>
                            <input type="checkbox" value="14" v-model="scoringRule.customHoles"> Hole 14<br>
                            <input type="checkbox" value="15" v-model="scoringRule.customHoles"> Hole 15<br>
                            <input type="checkbox" value="16" v-model="scoringRule.customHoles"> Hole 16<br>
                            <input type="checkbox" value="17" v-model="scoringRule.customHoles"> Hole 17<br>
                            <input type="checkbox" value="18" v-model="scoringRule.customHoles"> Hole 18<br>
                          </div>
                        </div>
                      </td>
                      <td>&nbsp;</td>
                    </tr>
                    <tr v-if="scoringRuleProtoAttribute(scoringRule.name, 'setupComponentName') === 'individual_stroke_play'">
                      <td>Tie-Breaking<br/><caption>18-hole tournaments use the back nine.</caption></td>
                      <td>
                        <input label="false" type="checkbox" class="form-control required form-control" :checked="customConfigurationValue('nineHoleTiebreaking', scoringRuleIndex)" @change="$emit('input', updateCustomConfigurationValue('nineHoleTiebreaking', scoringRuleIndex, $event.target.checked))">
                      </td>
                      <td>&nbsp;</td>
                    </tr>
                    <tr v-if="scoringRuleProtoAttribute(scoringRule.name, 'setupComponentName') === 'individual_stableford'">
                      <td>Stableford Scores</td>
                      <td>
                        <label>Double Eagle Score</label>
                        <input label="false" type="text" class="form-control string required form-control" :value="customConfigurationValue('doubleEagleScore', scoringRuleIndex)" @change="$emit('input', updateCustomConfigurationValue('doubleEagleScore', scoringRuleIndex, $event.target.value))">
                        <br/>
                        <label>Eagle Score</label>
                        <input label="false" type="text" class="form-control string required form-control" :value="customConfigurationValue('eagleScore', scoringRuleIndex)" @change="$emit('input', updateCustomConfigurationValue('eagleScore', scoringRuleIndex, $event.target.value))">
                        <br/>
                        <label>Birdie Score</label>
                        <input label="false" type="text" class="form-control string required form-control" :value="customConfigurationValue('birdieScore', scoringRuleIndex)" @change="$emit('input', updateCustomConfigurationValue('birdieScore', scoringRuleIndex, $event.target.value))">
                        <br/>
                        <label>Par Score</label>
                        <input label="false" type="text" class="form-control string required form-control" :value="customConfigurationValue('parScore', scoringRuleIndex)" @change="$emit('input', updateCustomConfigurationValue('parScore', scoringRuleIndex, $event.target.value))">
                        <br/>
                        <label>Bogey Score</label>
                        <input label="false" type="text" class="form-control string required form-control" :value="customConfigurationValue('bogeyScore', scoringRuleIndex)" @change="$emit('input', updateCustomConfigurationValue('bogeyScore', scoringRuleIndex, $event.target.value))">
                        <br/>
                        <label>Double Bogey Score</label>
                        <input label="false" type="text" class="form-control string required form-control" :value="customConfigurationValue('doubleBogeyScore', scoringRuleIndex)" @change="$emit('input', updateCustomConfigurationValue('doubleBogeyScore', scoringRuleIndex, $event.target.value))">
                      </td>
                      <td>&nbsp;</td>
                    </tr>
                    <tr v-if="scoringRuleProtoAttribute(scoringRule.name, 'setupComponentName') === 'three_best_balls_of_four'">
                      <td>Add each hole's par to the score if the group is not full.</td>
                      <td>
                        <input label="false" type="checkbox" class="form-control required form-control" :checked="customConfigurationValue('shouldAddParIfSmallGroup', scoringRuleIndex)" @change="$emit('input', updateCustomConfigurationValue('shouldAddParIfSmallGroup', scoringRuleIndex, $event.target.checked))">
                      </td>
                      <td>&nbsp;</td>
                    </tr>
                  </tbody>
                </table>

                <h5 class="card-title">
                  Payouts
                </h5>
                <table class="table">
                  <thead>
                    <tr class="text-uppercase">
                      <th scope="col" class="pl-5 pr-0">Flight</th>
                      <th scope="col">Points</th>
                      <th scope="col">$</th>
                      <th scope="col"><button type="button" class="btn__ezgl-secondary-outline float-right" v-on:click="newPayout(scoringRuleIndex)">Add</button></th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="(payout, payoutIndex) in scoringRule.payouts" :key="payout.id">
                      <th class="pl-5 pr-0">
                        <multiselect v-model="payout.flight" :options="flights" track-by="flightNumber" label="flightNumber" :searchable="false"></multiselect>
                      </th>
                      <td>
                        <input label="false" type="text" class="form-control string required form-control" :value="payoutAttributeValue('points', payoutIndex, scoringRuleIndex)" @change="$emit('input', updatePayoutAttributeValue('points', payoutIndex, scoringRuleIndex, $event.target.value))">
                      </td>
                      <td>
                        <input label="false" type="text" class="form-control string required form-control" :value="payoutAttributeValue('amount', payoutIndex, scoringRuleIndex)" @change="$emit('input', updatePayoutAttributeValue('amount', payoutIndex, scoringRuleIndex, $event.target.value))">
                      </td>
                      <td class="edit-link">
                        <button type="button" class="btn btn-default float-right" v-on:click="deletePayout(payoutIndex, scoringRuleIndex)">Remove</button>
                      </td>
                    </tr>
                  </tbody>
                </table>

                <button type="button" class="btn__ezgl-secondary-outline float-right" v-on:click="deleteScoringRule(scoringRuleIndex)">Delete Game</button>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" v-on:click="cancelEdit">Cancel</button>
        <button type="button" class="btn__ezgl-secondary" v-on:click="save">Save</button>
      </div>
    </form>
  </vue-modal>
</template>

<script>
import { mapMultiRowFields } from 'vuex-map-fields';
import Multiselect from 'vue-multiselect';

import store from '../../store/store';

export default {
  components: {
    Multiselect,
  },
  computed: {
    ...mapMultiRowFields('tournament', ['tournament.tournamentDays[0].course', 'tournament.tournamentDays[0].scoringRules', 'tournament.tournamentDays[0].flights', 'holeOptions']),
    availableScoringRules() {
      return this.$store.getters['tournament/availableScoringRules'];
    },
    groupedScoringRules() {
      return this.$store.getters['tournament/groupedScoringRules'];
    },
  },
  methods: {
    scoringRuleProtoAttribute(name, attributeName) {
      let attributeValue = null;

      this.availableScoringRules.forEach((rule) => {
        if (rule.name === name) {
          attributeValue = rule[attributeName];
        }
      });

      return attributeValue;
    },
    showCustomName(rule) {
      return this.scoringRuleProtoAttribute(rule.name, 'customNameAllowed');
    },
    showCourseHoles(rule) {
      return this.scoringRuleProtoAttribute(rule.name, 'showCourseHoles');
    },
    showCustomHoles(rule) {
      return rule.holeConfiguration.value === 'custom';
    },
    showBackNine() {
      return this.course.numberOfCourseHoles === 18;
    },
    customConfigurationValue(attribute, index) {
      return this.$store.getters['tournament/customScoringRuleConfigurationValue'](attribute, index);
    },
    updateCustomConfigurationValue(attribute, index, newValue) {
      this.$store.dispatch('tournament/updateCustomScoringRuleConfigurationValue', { attribute, index, newValue });
    },
    newScoringRule(value) {
      this.$store.dispatch('tournament/addScoringRule', { value });
    },
    deleteScoringRule(index) {
      this.$store.dispatch('tournament/deleteScoringRule', { index });
    },
    newPayout(index) {
      this.$store.dispatch('tournament/addScoringRulePayout', { index });
    },
    deletePayout(index, scoringRuleIndex) {
      this.$store.dispatch('tournament/deleteScoringRulePayout', { index, scoringRuleIndex });
    },
    payoutAttributeValue(attribute, index, scoringRuleIndex) {
      return this.$store.getters['tournament/payoutAttributeValue'](attribute, index, scoringRuleIndex);
    },
    updatePayoutAttributeValue(attribute, index, scoringRuleIndex, newValue) {
      this.$store.dispatch('tournament/updatePayoutAttributeValue', { attribute, index, scoringRuleIndex, newValue });
    },
    cancelEdit() {
      this.$modal.hide('scoring-rules-modal');
    },
    save() {
      this.$store.dispatch('tournament/saveScoringRules')
        .then(() => {
          this.$modal.hide('scoring-rules-modal');

          window.location.reload();
        });
    },
  },
};
</script>
