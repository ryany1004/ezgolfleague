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
    return {}
  }

  validation() {
    return {}
  }
}