import appsignal from "./appsignal.js"
import { errorHandler } from "@appsignal/vue";

import Vue from 'vue'
import App from './App.vue'

Vue.config.productionTip = false
Vue.config.errorHandler = errorHandler(appsignal, Vue);

new Vue({
  render: h => h(App),
}).$mount('#app')
