const uuidv1 = require('uuid/v1');

import {Model, Collection} from 'vue-mc'

export default class EZGLFlight extends Model {
  defaults() {
    return {
      id: uuidv1(),
      flightNumber: 1,
      lowHandicap: 0,
      highHandicap: 300,
      teeBox: null
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
}