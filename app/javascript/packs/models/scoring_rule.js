import { Model } from 'vue-mc';

const uuidv1 = require('uuid/v1');

export default class EZGLScoringRule extends Model {
  defaults() {
    return {
      id: uuidv1(),
      name: null,
      className: null,
      holeConfiguration: null,
      customConfiguration: {
        nineHoleTiebreaking: false,
      },
      isMandatory: true,
      duesAmount: 0,
      payouts: [],
    };
  }

  mutations() {
    return {};
  }

  validation() {
    return {};
  }

  canBeSubmitted() {
    return this.name != null && this.holeConfiguration != null;
  }
}
