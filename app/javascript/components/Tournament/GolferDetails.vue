<template>
  <vue-modal name="golfer-details-modal" height="auto" width="85%" :scrollable="false" @before-open="beforeOpen" class="edit-golfer-modal">
    <form onSubmit="return false">
      <div class="modal-body p-5">
        <div class="edit-golfer-modal__header">
          <div>
            <img :src=golfer.imageUrl class='img-circle'>
          </div>
          <div class="edit-golfer-modal__header__left pl-4">
            <h3>{{ golfer.name }}</h3>
            <template v-if="mandatoryDuesAmount > 0">
              <template v-if="golfer.duesPaid">
                <div class="dues-text">
                  <div class="paid"></div><p>Tournament Dues Paid</p>
                </div>
                <a href='#' class="btn btn-outline-dark" v-on:click="toggleDuesPayment">Mark Dues Unpaid</a>
              </template>
              <template v-else>
                <div class="dues-text">
                  <div class="unpaid"></div><p>Tournament Dues Unpaid</p>
                </div>
                <a href='#' class="btn btn-outline-dark" v-on:click="toggleDuesPayment">Mark Dues Paid</a>
              </template>
            </template>
          </div>
        </div>

        <div class="edit-golfer-modal__tee-times pt-5">
          <div class="form-subheader">
            <h6>Tee Time</h6>
          </div>

          <div class="time">
            <template v-if="editingTournamentGroup">
              <select v-model="golfer.tournamentGroupId">
                <option v-for="group in tournamentGroups" v-bind:key="group.id" v-bind:value="group.id">
                  {{ group.teeTime }}
                </option>
              </select>
            </template>
            <template v-else>
              <h5>{{ golfer.tournamentGroupTime }}</h5>
              <p v-on:click="editingTournamentGroup = !editingTournamentGroup">Edit</p>
            </template>
          </div>
        </div>

        <div class="edit-golfer-modal__contests pt-3 pb-3">
          <div class="form-subheader">
            <h6>Optional Game Types</h6>
          </div>

          <div class="checkbox" v-for="scoringRule in optionalScoringRules" :key="scoringRule.id">
            <input type="checkbox" v-bind:id="scoringRule.id" :value=scoringRule.id v-model="golfer.scoringRules">{{ scoringRule.name }}<br>
          </div>
        </div>
      </div>

      <div class="modal-footer edit-golfer-modal__footer">
        <a href='#' class='btn btn-outline-dark' v-on:click="removeGolfer">Remove Golfer</a>
        <button type="button" class="btn btn-default" v-on:click="cancelEdit">Cancel</button>
        <a href='#' class='btn btn__ezgl-secondary' v-on:click="save">Save</a>
      </div>
    </form>
  </vue-modal>
</template>

<script>
import GolferDetailsAPI from '../../api/GolferDetailsAPI';

export default {
  data() {
    return {
      csrfToken: document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
      leagueId: null,
      tournamentId: null,
      tournamentDayId: null,
      mandatoryDuesAmount: null,
      golfer: {
        id: null,
        imageUrl: null,
        name: null,
        shortName: null,
        duesPaid: false,
        tournamentGroupId: null,
        tournamentGroupTime: null,
        scoringRules: [],
      },
      editingTournamentGroup: false,
      tournamentGroups: [],
      scoringRules: [],
    };
  },
  computed: {
    optionalScoringRules() {
      return this.scoringRules.filter((rule) => rule.isOptIn);
    },
  },
  methods: {
    beforeOpen(event) {
      this.golfer = event.params.payload.golfer;
      this.tournamentGroups = event.params.payload.tournamentGroups;
      this.scoringRules = event.params.payload.scoringRules;
      this.leagueId = event.params.payload.leagueId;
      this.tournamentId = event.params.payload.tournamentId;
      this.tournamentDayId = event.params.payload.tournamentDayId;
      this.mandatoryDuesAmount = event.params.payload.mandatoryDuesAmount;
    },
    toggleDuesPayment() {
      this.golfer.duesPaid = !this.golfer.duesPaid;
    },
    cancelEdit() {
      this.$modal.hide('golfer-details-modal');
    },
    removeGolfer() {
      GolferDetailsAPI.destroyGolferDetails(this.csrfToken, this.leagueId, this.tournamentId, this.tournamentDayId, this.golfer.id)
        .then(() => {
          window.location.reload();
        });
    },
    save() {
      GolferDetailsAPI.patchGolferDetails(this.csrfToken, this.leagueId, this.tournamentId, this.tournamentDayId, this.golfer.id, this.golfer)
        .then(() => {
          window.location.reload();
        });
    },
  },
};
</script>
