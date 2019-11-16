const uuidv1 = require('uuid/v1');

import {Model, Collection} from 'vue-mc'

export default class EZGLPayout extends Model {
  defaults() {
    return {
      id: uuidv1(),
      flight: null,
      points: null,
      amount: null
    }
  }

  mutations() {
    return {
      id: (id) => Number(id) || null,
      flightNumber: (flightNumber) => Number(flightNumber) || null,
      lowHandicap: (lowHandicap) => Number(lowHandicap) || null,
      highHandicap: (highHandicap) => Number(highHandicap) || null
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