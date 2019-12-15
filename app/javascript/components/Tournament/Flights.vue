<template>
  <vue-modal name="flights-modal" height="auto" width="85%" :scrollable="true">
    <link rel="stylesheet" href="https://unpkg.com/vue-multiselect@2.1.0/dist/vue-multiselect.min.css">

    <form onSubmit="return false">
      <div class="welcome p-5">
        <div class="p-3">
          <h2 style="font-size:30px;">Flights</h2>
        </div>

        <table class="table">
          <thead>
            <tr class="text-uppercase">
              <th scope="col" class="pl-5 pr-0">Flight</th>
              <th scope="col">Low Handicap</th>
              <th scope="col">High Handicap</th>
              <th scope="col">Tee Box</th>
              <th scope="col"><button type="button" class="btn__ezgl-secondary-outline float-right" v-on:click="newFlight">Add</button></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(flight, index) in flights" v-bind:key="flight.flightNumber">
              <th class="pl-5 pr-0">{{ flight.flightNumber }}</th>
              <td><input label="false" type="text" class="form-control string required form-control" v-model="flight.lowerBound"></td>
              <td><input label="false" type="text" class="form-control string required form-control" v-model="flight.upperBound"></td>
              <td>
                <multiselect v-model="flight.courseTeeBox" track-by="id" label="name" placeholder="Select" :options="courseTeeBoxes" :searchable="false" :allow-empty="false"></multiselect>
              </td>
              <td class="edit-link">
                <button type="button" class="btn btn-default float-right" v-on:click="deleteFlight(index)" v-if="index > 0">Remove</button>
              </td>
            </tr>
          </tbody>
        </table>
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
    ...mapMultiRowFields('tournament', ['tournament.tournamentDays[0].flights', 'tournament.tournamentDays[0].course.courseTeeBoxes']),
  },
  methods: {
    newFlight() {
      this.$store.dispatch('tournament/addFlight');
    },
    deleteFlight(index) {
      this.$store.dispatch('tournament/deleteFlight', { index });
    },
    cancelEdit() {
      this.$modal.hide('flights-modal');
    },
    save() {
      this.$store.dispatch('tournament/saveFlights')
        .then(() => {
          this.$modal.hide('flights-modal');

          window.location.reload();
        });
    },
  },
};
</script>
