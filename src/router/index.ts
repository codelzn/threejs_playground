import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router';

import Index from '../views/Index.vue';
import Lantern from '../views/Lantern.vue';
import Water from '../views/Water.vue';
import Newwater from '../views/Newwater.vue';

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'index',
    component: Index,
  },
  {
    path: '/lantern',
    name: 'lantern',
    component: Lantern,
  },
  {
    path: '/water',
    name: 'water',
    component: Water,
  },
  {
    path: '/newwater',
    name: 'newwater',
    component: Newwater,
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});
export default router;
