import 'bootstrap/dist/css/bootstrap.css';
import 'bootstrap-vue-next/dist/bootstrap-vue-next.css';
import 'primevue/resources/primevue.min.css';
import 'primevue/resources/themes/bootstrap4-dark-blue/theme.css';
import 'primeflex/primeflex.css';
import 'primeicons/primeicons.css';
import '@/assets/css/style.scss';
import { createApp } from 'vue';
import { createPinia } from 'pinia';
import BootstrapVueNext from 'bootstrap-vue-next';
import PrimeVue from 'primevue/config';
import App from './App.vue';

const pinia = createPinia();
const app = createApp(App);

app.use(pinia);
app.use(BootstrapVueNext);
app.use(PrimeVue);
app.mount('#app');
