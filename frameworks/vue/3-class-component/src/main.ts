import appsignal from "./appsignal";
import { errorHandler } from "@appsignal/vue";

import { createApp } from "vue";
import App from "./App.vue";

const app = createApp(App);
app.config.errorHandler = errorHandler(appsignal, app);
app.mount("#app");
