import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router';

import Index from '../views/Index.vue';
import Lantern from '../views/Lantern.vue';
import Water from '../views/Water.vue';
import Newwater from '../views/Newwater.vue';
import Galaxy from '../views/Galaxy.vue';
import FireWork from '../views/Firework.vue';
import WithCss from '../views/Withcss.vue'
import Flower from '../views/Flower.vue'

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
  {
    path: '/galaxy',
    name: 'galaxy',
    component: Galaxy,
  },
  {
    path: '/firework',
    name: 'firework',
    component: FireWork,
  },
  {
    path: '/withcss',
    name: 'withcss',
    component: WithCss,
  },
  {
    path: '/flower',
    name: 'flower',
    component: Flower,
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});
export default router;
