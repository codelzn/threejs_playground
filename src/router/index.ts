import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router';

import Index from '../views/Index.vue';

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'index',
    component: Index,
  },
  {
    path: '/lantern',
    name: 'lantern',
    component: () => import('../views/Lantern.vue'),
  },
  {
    path: '/water',
    name: 'water',
    component: () => import('../views/Water.vue'),
  },
  {
    path: '/newwater',
    name: 'newwater',
    component: () => import('../views/Newwater.vue'),
  },
  {
    path: '/galaxy',
    name: 'galaxy',
    component: () => import('../views/Galaxy.vue'),
  },
  {
    path: '/firework',
    name: 'firework',
    component: () => import('../views/Firework.vue'),
  },
  {
    path: '/withcss',
    name: 'withcss',
    component: () => import('../views/Withcss.vue'),
  },
  {
    path: '/sampleanime',
    name: 'sampleanime',
    component: () => import('../views/SampleAnime.vue'),
  },
  {
    path: '/taotajima',
    name: 'taotajima',
    component: () => import('../views/Taotajima.vue'),
  },
  {
    path: '/transition1',
    name: 'transition1',
    component: () => import('../views/Transition1.vue'),
  },
  {
    path: '/transition2',
    name: 'transition2',
    component: () => import('../views/Transition2.vue'),
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});
export default router;
