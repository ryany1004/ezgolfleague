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
    return {
        // flightNumber: (flightNumber) => Number(flightNumber) || null,
        // lowHandicap: (lowHandicap) => Number(lowHandicap) || null,
        // highHandicap: (highHandicap) => Number(highHandicap) || null
    }
  }

  validation() {
    return {
      // id:   integer.and(min(1)).or(equal(null)),
      // name: string.and(required),
      // done: boolean,
    }
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
