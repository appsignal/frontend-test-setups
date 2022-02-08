import appsignal from "./appsignal.js"

import { createApp } from 'vue'
import App from './App.vue'
import router from './router'


import { errorHandler } from "@appsignal/vue";

const app = createApp(App)
// app.config.errorHandler = errorHandler(appsignal, app)
app.use(router).mount('#app')

