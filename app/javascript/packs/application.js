/* eslint no-console:0 */

import Vue from 'vue/dist/vue.esm.js';
import App from '../components/app.vue'

document.addEventListener('DOMContentLoaded', () => {
  document.body.appendChild(document.createElement('app'))
  const app = new Vue({
    el: 'app',
    template: '<App/>',
    components: { App }
  })

  console.log(app)
})

/*

This is an example of a Vue component where the component bit is stored and loaded from ../components/app.vue.

You can also interact with the page directly, see tournament_wizard.js.

*/