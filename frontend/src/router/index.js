import { createRouter, createWebHistory } from 'vue-router'
import AppLayout from '@/layouts/AppLayout.vue'
import DashboardView from '@/views/DashboardView.vue'
import HistoryView from '@/views/HistoryView.vue'
import OverviewView from '@/views/OverviewView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      component: AppLayout,
      children: [
        {
          path: '',
          name: 'dashboard',
          component: DashboardView
        },
        {
          path: 'history',
          name: 'history',
          component: HistoryView
        },
        {
          path: 'overview',
          name: 'overview',
          component: OverviewView
        }
      ]
    }
  ]
})

export default router
