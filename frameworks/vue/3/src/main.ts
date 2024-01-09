import './assets/main.css'

import appsignal from "./appsignal";
import { errorHandler } from "@appsignal/vue";

import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

const app = createApp(App)
app.config.errorHandler = errorHandler(appsignal, app);
app.use(router)

app.mount('#app')
