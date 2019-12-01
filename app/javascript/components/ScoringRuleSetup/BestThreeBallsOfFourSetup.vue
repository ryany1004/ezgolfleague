<template>
  <div class="step-1-content-form step-1-content pt-2">
    <div class="row">
      <div class="col-md-3 text-right vue-label">
        <label>Par Addition</label>
      </div>
      <div class="col-md-8 tee-times-inputs">
        <div class="col-md-8 p-0">
          <input type="checkbox" name="add-par-small-group" v-model="setupOptions.shouldAddParIfSmallGroup" @change="updateParGroup">Add each hole's par to the score if the group is not full.
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
        shouldAddParIfSmallGroup: true,
      },
    };
  },
  methods: {
    updateParGroup() {
      this.$emit('game-type-options-changed', this.setupOptions);
    },
  },
};
</script>
