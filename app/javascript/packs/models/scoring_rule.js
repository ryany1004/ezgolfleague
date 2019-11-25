const uuidv1 = require('uuid/v1');

import {Model, Collection} from 'vue-mc'

export default class EZGLScoringRule extends Model {
  defaults() {
    return {
      id: uuidv1(),
      name: null,
      className: null,
      holeConfiguration: null,
      customConfiguration: {
        nineHoleTiebreaking: false
      },
      payouts: []
    }
  }

  mutations() {
    return {}
  }

  validation() {
    return {}
  }

  canBeAssigned() {
    if (this.name == null) {
      return true;
    } else {
      return false;
    }
  }

  canBeSubmitted() {
    return !this.canBeAssigned();
  }
}
