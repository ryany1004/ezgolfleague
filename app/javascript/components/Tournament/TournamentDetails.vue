<template>
  <vue-modal name="tournament-details-modal" height="auto" width="85%" :scrollable="false" @before-open="beforeOpenDetails">
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
                    <input label="false" required="required" aria-required="true" placeholder="Choose a name..." type="text" id="name" class="form-control string required form-control" v-model="tournament.name">
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
                        <date-picker v-model="tournament.startsAt"></date-picker>
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
                        <date-picker v-model="tournament.opensAt"></date-picker>
                      </div>
                      <div class="col-md-6" style="padding-right: 40px;">
                        <date-picker v-model="tournament.closesAt"></date-picker>
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
                          <input label="false" required="required" aria-required="true" placeholder="How Many People Can Register?" type="text" id="name" style="width: 80px;" class="form-control string required form-control" v-model="tournament.numberOfPlayers">
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
                  <toggle-button id="show-tee-times" v-model="tournament.showTeeTimes" :labels="{checked: 'yes', unchecked: 'no'}"/>
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
import datePicker from 'vue-bootstrap-datetimepicker';
import { ToggleButton } from 'vue-js-toggle-button';
import api from 'api';

export default {
  components: {
    datePicker,
    ToggleButton,
  },
  data() {
    return {
      tournament: {
        name: null,
        startsAt: null,
        opensAt: null,
        closesAt: null,
        numberOfPlayers: 0,
        enterScoresUntilFinalized: false,
        showTeeTimes: false,
      },
      leagueId: null,
      tournamentId: null,
      tournamentDayId: null,
      csrfToken: null,
      saveErrors: [],
    };
  },
  methods: {
    beforeOpenDetails(event) {
      this.csrfToken = event.params.csrfToken;

      this.leagueId = event.params.tournament.leagueId;
      this.tournamentId = event.params.tournament.tournamentId;
      this.tournamentDayId = event.params.tournament.tournamentDayId;

      this.tournament = event.params.tournament;
      this.tournament.startsAt = new Date(this.tournament.startsAt);
      this.tournament.opensAt = new Date(this.tournament.opensAt);
      this.tournament.closesAt = new Date(this.tournament.closesAt);
    },
    cancelEdit() {
      this.$modal.hide('tournament-details-modal');
    },
    save() {
      const tournamentDetailsPayload = this.tournament;
      tournamentDetailsPayload.leagueId = this.leagueId;
      tournamentDetailsPayload.tournamentId = this.tournamentId;
      tournamentDetailsPayload.tournamentDayId = this.tournamentDayId;

      api.patchTournamentDetails(this.csrfToken, tournamentDetailsPayload)
        .then((response) => {
          if (response.data.errors.length > 0) {
            this.$modal.hide('tournament-details-modal');

            window.location.href = response.data.url;
          }
        });
    },
  },
};
</script>
