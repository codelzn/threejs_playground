import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router';

import Index from '../views/Index.vue';
import Lantern from '../views/Lantern.vue';
import Water from '../views/Water.vue';
import Newwater from '../views/Newwater.vue';
import Galaxy from '../views/Galaxy.vue';
import FireWork from '../views/Firework.vue';
import Debug from '../views/Debug.vue';
import ShaderTest from '../views/ShaderTest.vue';

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
    path: '/debug',
    name: 'debug',
    component: Debug,
  },
  {
    path: '/test',
    name: 'test',
    component: ShaderTest,
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});
export default router;
