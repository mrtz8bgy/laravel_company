<script setup lang="ts">
import { computed, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useAuthStore } from '../stores/auth'
import { useUiStore } from '../stores/ui'
import { applyLocale } from '../i18n'
import CommandPalette from '../components/CommandPalette.vue'

const auth = useAuthStore()
const ui = useUiStore()
const route = useRoute()
const router = useRouter()
const { t, locale } = useI18n()

const groups = computed(() => [
  {
    label: t('navWork'),
    items: [
      { to: '/', label: t('dashboard'), show: true },
      { to: '/attendance', label: t('attendance'), show: auth.feature('attendance') && auth.can('attendance.clock') },
      { to: '/attendance/board', label: t('attendanceBoard'), show: auth.feature('attendance') && auth.can('attendance.view') },
      { to: '/projects', label: t('projects'), show: auth.feature('projects') && auth.can('projects.view') },
      { to: '/calendar', label: t('calendar'), show: auth.feature('calendar') && auth.can('calendar.view') },
      { to: '/inbox', label: t('inbox'), show: auth.feature('communication') && auth.can('messages.view') },
    ],
  },
  {
    label: t('navCompany'),
    items: [
      { to: '/people', label: t('people'), show: auth.can('users.view') },
      { to: '/departments', label: t('departments'), show: auth.can('departments.view') },
      { to: '/teams', label: t('teams'), show: auth.can('teams.view') },
      { to: '/hr', label: t('hr'), show: auth.feature('hr') && (auth.can('leave.request') || auth.can('hr.profile.view')) },
      { to: '/documents', label: t('documents'), show: auth.feature('documents') && auth.can('documents.view') },
    ],
  },
  {
    label: t('navBusiness'),
    items: [
      { to: '/crm', label: t('crm'), show: auth.feature('crm') && auth.can('crm.view') },
      { to: '/marketing', label: t('marketing'), show: auth.feature('marketing') && auth.can('marketing.view') },
      { to: '/finance', label: t('finance'), show: auth.feature('finance') && auth.can('finance.view') },
      { to: '/tickets', label: t('tickets'), show: auth.feature('operations') && auth.can('tickets.create') },
      { to: '/approvals', label: t('approvals'), show: auth.feature('workflows') && auth.can('workflows.request') },
      { to: '/analytics', label: t('analytics'), show: auth.feature('analytics') && auth.can('analytics.view') },
    ],
  },
  {
    label: t('navSystem'),
    items: [
      { to: '/roles', label: t('roles'), show: auth.can('roles.view') },
      { to: '/activity', label: t('activity'), show: auth.can('activity_logs.view') },
      { to: '/settings', label: t('settings'), show: auth.can('company.view') },
      { to: '/profile', label: t('profile'), show: true },
    ],
  },
].map((group) => ({ ...group, items: group.items.filter((item) => item.show) })).filter((group) => group.items.length))

function onKey(event: KeyboardEvent) {
  if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 'k') {
    event.preventDefault()
    ui.palette = true
  }
}

onMounted(() => window.addEventListener('keydown', onKey))
onUnmounted(() => window.removeEventListener('keydown', onKey))

async function logout() {
  await auth.logout()
  router.push('/login')
}

function toggleLocale() {
  applyLocale(locale.value === 'fa' ? 'en' : 'fa')
}
</script>

<template>
  <div class="min-h-screen lg:grid lg:grid-cols-[280px_1fr]">
    <aside
      class="fixed inset-y-0 start-0 z-40 w-[280px] flex-col bg-ink text-white lg:static lg:flex"
      :class="ui.sidebar ? 'flex' : 'hidden lg:flex'"
    >
      <div class="border-b border-white/10 px-5 py-5">
        <div class="flex items-center gap-3">
          <span class="mark"><span /></span>
          <div class="min-w-0">
            <p class="truncate text-sm font-semibold">{{ t('brand') }}</p>
            <p class="truncate text-xs text-white/45">{{ auth.company?.name }}</p>
          </div>
        </div>
      </div>
      <nav class="flex-1 overflow-auto px-3 py-3">
        <div v-for="group in groups" :key="group.label">
          <p class="nav-label">{{ group.label }}</p>
          <router-link v-for="item in group.items" :key="item.to" :to="item.to" class="nav-link" @click="ui.sidebar = false">
            <span class="h-1.5 w-1.5 rounded-full bg-brass" />
            {{ item.label }}
          </router-link>
        </div>
      </nav>
      <div class="border-t border-white/10 p-4">
        <p class="truncate text-sm font-medium">{{ auth.user?.name }}</p>
        <p class="truncate text-xs text-white/45">{{ auth.user?.job_title || auth.user?.email }}</p>
        <button class="btn btn-ghost mt-3 w-full !border-white/15 !bg-transparent !text-white" @click="logout">{{ t('logout') }}</button>
      </div>
    </aside>
    <div v-if="ui.sidebar" class="fixed inset-0 z-30 bg-ink/50 lg:hidden" @click="ui.sidebar = false" />
    <div class="min-w-0">
      <header class="sticky top-0 z-20 flex items-center gap-3 border-b border-line bg-paper-2/80 px-4 py-3 backdrop-blur">
        <button class="btn btn-ghost lg:hidden" @click="ui.sidebar = true">☰</button>
        <button class="btn btn-ghost min-w-0 flex-1 justify-between text-muted" @click="ui.palette = true">
          <span>{{ t('search') }}</span>
          <kbd class="rounded-lg border border-line px-2 py-0.5 text-xs">Ctrl K</kbd>
        </button>
        <button class="btn btn-ghost" @click="toggleLocale">{{ t('language') }}</button>
      </header>
      <main class="mx-auto w-full max-w-6xl px-4 py-7 sm:px-6">
        <router-view :key="route.fullPath" />
      </main>
    </div>
    <CommandPalette />
  </div>
</template>
