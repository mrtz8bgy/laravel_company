import { createRouter, createWebHistory } from 'vue-router'
import { appBasePath } from '../api/client'
import { useAuthStore } from '../stores/auth'

const base = appBasePath()

const router = createRouter({
  history: createWebHistory(base ? `${base}/` : '/'),
  routes: [
    { path: '/login', component: () => import('../pages/LoginPage.vue'), meta: { guest: true } },
    {
      path: '/portal',
      component: () => import('../layouts/PortalShell.vue'),
      children: [
        { path: '', component: () => import('../pages/PortalHomePage.vue'), meta: { auth: true, portal: true } },
        { path: 'profile', component: () => import('../pages/PortalProfilePage.vue'), meta: { auth: true, portal: true } },
        { path: 'orders', component: () => import('../pages/PortalOrdersPage.vue'), meta: { auth: true, portal: true } },
        { path: 'messages', component: () => import('../pages/PortalMessagesPage.vue'), meta: { auth: true, portal: true } },
        { path: 'tickets', component: () => import('../pages/PortalTicketsPage.vue'), meta: { auth: true, portal: true } },
        { path: 'register', component: () => import('../pages/PortalRegisterPage.vue'), meta: { guest: true, portal: true } },
      ],
    },
    { path: '/forgot-password', component: () => import('../pages/ForgotPasswordPage.vue'), meta: { guest: true } },
    { path: '/reset-password', component: () => import('../pages/ResetPasswordPage.vue'), meta: { guest: true } },
    { path: '/accept-invite', component: () => import('../pages/AcceptInvitePage.vue'), meta: { guest: true } },
    { path: '/onboarding', component: () => import('../pages/OnboardingPage.vue') },
    { path: '/', component: () => import('../pages/DashboardPage.vue'), meta: { auth: true } },
    { path: '/attendance', component: () => import('../pages/AttendancePage.vue'), meta: { auth: true } },
    { path: '/attendance/board', component: () => import('../pages/AttendanceBoardPage.vue'), meta: { auth: true } },
    { path: '/projects', component: () => import('../pages/ProjectsPage.vue'), meta: { auth: true } },
    { path: '/projects/:uuid', component: () => import('../pages/ProjectBoardPage.vue'), meta: { auth: true } },
    { path: '/hr', component: () => import('../pages/HrPage.vue'), meta: { auth: true } },
    { path: '/inbox', component: () => import('../pages/InboxPage.vue'), meta: { auth: true } },
    { path: '/calendar', component: () => import('../pages/CalendarPage.vue'), meta: { auth: true } },
    { path: '/crm', component: () => import('../pages/CrmPage.vue'), meta: { auth: true } },
    { path: '/marketing', component: () => import('../pages/MarketingPage.vue'), meta: { auth: true } },
    { path: '/finance', component: () => import('../pages/FinancePage.vue'), meta: { auth: true } },
    { path: '/tickets', component: () => import('../pages/TicketsPage.vue'), meta: { auth: true } },
    { path: '/approvals', component: () => import('../pages/ApprovalsPage.vue'), meta: { auth: true } },
    { path: '/documents', component: () => import('../pages/DocumentsPage.vue'), meta: { auth: true } },
    { path: '/analytics', component: () => import('../pages/AnalyticsPage.vue'), meta: { auth: true } },
    { path: '/departments', component: () => import('../pages/DepartmentsPage.vue'), meta: { auth: true } },
    { path: '/teams', component: () => import('../pages/TeamsPage.vue'), meta: { auth: true } },
    { path: '/people', component: () => import('../pages/PeoplePage.vue'), meta: { auth: true } },
    { path: '/customers', component: () => import('../pages/CustomersPage.vue'), meta: { auth: true } },
    { path: '/people/:uuid', component: () => import('../pages/PersonPage.vue'), meta: { auth: true } },
    { path: '/people/:uuid/work', component: () => import('../pages/PersonWorkPage.vue'), meta: { auth: true } },
    { path: '/roles', component: () => import('../pages/RolesPage.vue'), meta: { auth: true } },
    { path: '/activity', component: () => import('../pages/ActivityPage.vue'), meta: { auth: true } },
    { path: '/settings', component: () => import('../pages/SettingsPage.vue'), meta: { auth: true } },
    { path: '/profile', component: () => import('../pages/ProfilePage.vue'), meta: { auth: true } },
    { path: '/:pathMatch(.*)*', redirect: '/login' },
  ],
})

router.beforeEach(async (to) => {
  const auth = useAuthStore()
  if (!auth.ready) await auth.fetchMe()
  if (to.meta.auth && !auth.token) return '/login'
  if (to.meta.guest && auth.token && to.path === '/login') return auth.isCustomer ? '/portal' : '/'
  if (to.path === '/portal/register' && auth.token && auth.isCustomer) return '/portal'
  if (to.path === '/onboarding' && auth.token && auth.onboarded) return '/'
  if (to.meta.auth && auth.token && !auth.onboarded && to.path !== '/profile' && !to.path.startsWith('/portal')) return '/onboarding'
  if (auth.token && auth.isCustomer && to.meta.auth && !to.path.startsWith('/portal')) return '/portal'
  return true
})

export default router
