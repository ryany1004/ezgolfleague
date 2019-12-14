<template>
  <vue-modal name="tournament-details-modal" height="auto" width="85%" :scrollable="false">
    <form onSubmit="return false">
      <div class="step-1-content p-3">
        <h2>Tournament Details</h2>
        <div class="step-1-content-form">
          <div class="form-group">
            <div class="row">
              <div class="col-md-4 text-right">
                <label>Tournament Name</label>
              </div>
                <div class="col-md-5">
                  <div class="string required tournament_name">
                    <input label="false" required="required" aria-required="true" placeholder="Choose a name..." type="text" id="name" class="form-control string required form-control" v-model="name">
                  </div>
              </div>
            </div>
          </div> 
          <div class="form-group">
            <div class="row">
              <div class="col-md-4 text-right">
                <label>Tournament Date</label>
              </div>
                <div class="col-md-5">
                  <div class="date-inputs" style="padding-right:24px;">
                    <div class="row">
                      <div class="col-12">
                        <date-picker v-model="startsAt"></date-picker>
                      </div>
                    </div>
                  </div>
              </div>
            </div>
          </div> 
          <div class="form-group">
            <div class="row">
              <div class="col-md-4 text-right">
                <label>Registration Dates</label>
              </div>
                <div class="col-md-5">
                  <div class="date-inputs">
                    <div class="row">
                      <div class="col-md-6">
                        <date-picker v-model="opensAt"></date-picker>
                      </div>
                      <div class="col-md-6" style="padding-right: 40px;">
                        <date-picker v-model="closesAt"></date-picker>
                      </div>
                    </div>
                  </div>
              </div>
            </div>
          </div> 
          <div class="form-group" style="margin-bottom:15px;">
            <div class="row">
              <div class="col-md-4 text-right">
                <label>Number of Players</label>
              </div>
                <div class="col-md-5">
                  <div style="padding-right:24px;">
                    <div class="row">
                      <div class="col-12">
                        <div class="form-group string required">
                          <input label="false" required="required" aria-required="true" placeholder="How Many People Can Register?" type="text" id="name" style="width: 80px;" class="form-control string required form-control" v-model="numberOfPlayers">
                        </div>
                      </div>
                    </div>
                  </div>
              </div>
            </div>
          </div> 
          <div class="form-group">
              <div class="row">
                <div class="col-md-4 text-right">
                  <label>Players Should<br>See Tee-Times</label>
                </div>
                <div class="col-md-5 text-left" style="margin-left: 20px;">
                  <toggle-button id="show-tee-times" v-model="showTeeTimes" :labels="{checked: 'yes', unchecked: 'no'}"/>
                </div>
              </div>
          </div>
        </div>
      </div>
      <div class="cat-card-footer">
          <button type="button" class="btn btn-outline-secondary" v-on:click="cancelEdit">Cancel</button>
          <button class="btn btn__ezgl-secondary" v-on:click="save">Save</button>
      </div>
    </form>
  </vue-modal>
</template>

<script>
import { createHelpers } from 'vuex-map-fields';

import datePicker from 'vue-bootstrap-datetimepicker';
import { ToggleButton } from 'vue-js-toggle-button';

import store from '../../store/store';

const { mapFields } = createHelpers({
  getterType: 'tournament/getField',
  mutationType: 'tournament/updateField',
});

export default {
  components: {
    datePicker,
    ToggleButton,
  },
  computed: {
    ...mapFields([
      'tournament.name',
      'tournament.startsAt',
      'tournament.opensAt',
      'tournament.closesAt',
      'tournament.numberOfPlayers',
      'tournament.enterScoresUntilFinalized',
      'tournament.showTeeTimes',
    ]),
  },
  methods: {
    cancelEdit() {
      this.$modal.hide('tournament-details-modal');
    },
    save() {
      this.$store.dispatch('tournament/saveTournamentDetails')
        .then(() => {
          this.$modal.hide('tournament-details-modal');

          window.location.reload();
        });
    },
  },
};
</script>
