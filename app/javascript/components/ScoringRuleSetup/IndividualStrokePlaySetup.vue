<template>
  <div class="step-1-content-form step-1-content pt-2">
    <div class="row">
      <div class="col-md-3 text-right vue-label">
        <label>Tie-Breaking</label>
      </div>
      <div class="col-md-8 tee-times-inputs">
        <div class="col-md-8 p-0">
          <input type="checkbox" name="nine_hole_tiebreaking" v-model="setupOptions.nineHoleTiebreaking" @change="updateTiebreaking"> 18-hole tournaments use the back nine.
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
        nineHoleTiebreaking: false,
      },
    };
  },
  methods: {
    updateTiebreaking() {
      this.$emit('game-type-options-changed', this.setupOptions);
    },
  },
};
</script>
