<template>
  <div class="text-left">
    <ul>
      <li v-for="(error, index) in formattedErrors" :key="index">{{ error }}</li>
    </ul>
  </div>
</template>

<script>
export default {
  props: {
    errors: Array,
  },
  computed: {
    formattedErrors() {
      const friendlyErrors = [];

      this.errors.forEach((error) => {
        Object.entries(error).forEach((errorElement) => {
          const key = errorElement[0];
          const value = errorElement[1];
          const friendlyName = this.renamedKeyForKey(key);

          value.forEach((fieldError) => {
            friendlyErrors.push(`${friendlyName} ${fieldError}.`);
          });
        });
      });

      return friendlyErrors;
    },
  },
  methods: {
    renamedKeyForKey(key) {
      switch (key) {
        case 'tournamentAt':
          return 'Tournament start date';
        case 'signupOpensAt':
          return 'Registration open date';
        case 'signupClosesAt':
          return 'Registration close date';
        default:
          return key;
      }
    },
  },
};
</script>
