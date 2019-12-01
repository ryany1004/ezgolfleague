<template>
  <div class="step-1-content-form step-1-content pt-2">
    <div class="row">
      <div class="col-md-3 text-right vue-label">
        <label>Stableford Settings</label>
      </div>
      <div class="col-md-8 tee-times-inputs">
        <div class="col-md-8 p-0">
          <label>Double Eagle Score</label>
          <input label="false" type="text" class="form-control string required form-control" v-model="setupOptions.doubleEagleScore" @change="updateStableford">

          <label>Eagle Score</label>
          <input label="false" type="text" class="form-control string required form-control" v-model="setupOptions.eagleScore" @change="updateStableford">

          <label>Birdie Score</label>
          <input label="false" type="text" class="form-control string required form-control" v-model="setupOptions.birdieScore" @change="updateStableford">

          <label>Par Score</label>
          <input label="false" type="text" class="form-control string required form-control" v-model="setupOptions.parScore" @change="updateStableford">

          <label>Bogey Score</label>
          <input label="false" type="text" class="form-control string required form-control" v-model="setupOptions.bogeyScore" @change="updateStableford">

          <label>Double Bogey Score</label>
          <input label="false" type="text" class="form-control string required form-control" v-model="setupOptions.doubleBogeyScore" @change="updateStableford">
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      setupOptions: {
        doubleEagleScore: 16,
        eagleScore: 8,
        birdieScore: 4,
        parScore: 2,
        bogeyScore: 1,
        doubleBogeyScore: 0,
      },
    };
  },
  methods: {
    updateStableford() {
      this.$emit('game-type-options-changed', this.setupOptions);
    },
  },
};
</script>
