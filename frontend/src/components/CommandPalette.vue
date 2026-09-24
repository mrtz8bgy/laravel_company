<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { api } from '../api/client'
import { useUiStore } from '../stores/ui'
import { useAuthStore } from '../stores/auth'

const ui = useUiStore()
const auth = useAuthStore()
const router = useRouter()
const { t } = useI18n()
const query = ref('')
const results = ref<{ type: string; uuid: string; name: string; email?: string }[]>([])

const actions = computed(() => [
  { label: t('dashboard'), to: '/' },
  { label: t('attendance'), to: '/attendance', show: auth.feature('attendance') && auth.can('attendance.clock') },
  { label: t('attendanceBoard'), to: '/attendance/board', show: auth.feature('attendance') && auth.can('attendance.view') },
  { label: t('projects'), to: '/projects', show: auth.feature('projects') && auth.can('projects.view') },
  { label: t('hr'), to: '/hr', show: auth.feature('hr') && (auth.can('leave.request') || auth.can('hr.profile.view')) },
  { label: t('inbox'), to: '/inbox', show: auth.feature('communication') && auth.can('messages.view') },
  { label: t('calendar'), to: '/calendar', show: auth.feature('calendar') && auth.can('calendar.view') },
  { label: t('crm'), to: '/crm', show: auth.feature('crm') && auth.can('crm.view') },
  { label: t('finance'), to: '/finance', show: auth.feature('finance') && auth.can('finance.view') },
  { label: t('analytics'), to: '/analytics', show: auth.feature('analytics') && auth.can('analytics.view') },
  { label: t('departments'), to: '/departments', show: auth.can('departments.view') },
  { label: t('teams'), to: '/teams', show: auth.can('teams.view') },
  { label: t('people'), to: '/people', show: auth.can('users.view') },
  { label: t('roles'), to: '/roles', show: auth.can('roles.view') },
  { label: t('settings'), to: '/settings' },
  { label: t('profile'), to: '/profile' },
].filter((item) => item.show !== false))

watch(query, async (value) => {
  if (value.trim().length < 2) {
    results.value = []
    return
  }
  const response = await api<{ users: any[]; departments: any[]; teams: any[]; projects?: any[] }>(`/search?q=${encodeURIComponent(value)}`)
  results.value = [...response.data.users, ...response.data.departments, ...response.data.teams, ...(response.data.projects || [])]
})

function go(path: string) {
  ui.palette = false
  query.value = ''
  router.push(path)
}

function openResult(item: { type: string; uuid: string }) {
  if (item.type === 'project') {
    go(`/projects/${item.uuid}`)
    return
  }
  const map: Record<string, string> = { user: '/people', department: '/departments', team: '/teams' }
  go(map[item.type] || '/')
}
</script>

<template>
  <div v-if="ui.palette" class="fixed inset-0 z-50 flex items-start justify-center bg-ink/40 px-4 pt-[12vh]" @click.self="ui.palette = false">
    <div class="panel w-full max-w-xl overflow-hidden">
      <input v-model="query" autofocus class="w-full border-0 bg-transparent px-5 py-4 text-base outline-none" :placeholder="t('search')" />
      <div class="max-h-80 overflow-auto border-t border-line p-2">
        <button v-for="action in actions" :key="action.to" class="flex w-full rounded-xl px-3 py-2 text-start hover:bg-paper" @click="go(action.to)">
          {{ action.label }}
        </button>
        <button v-for="item in results" :key="item.type + item.uuid" class="flex w-full items-center justify-between rounded-xl px-3 py-2 text-start hover:bg-paper" @click="openResult(item)">
          <span>{{ item.name }}</span>
          <span class="text-xs text-muted">{{ item.type }}</span>
        </button>
      </div>
    </div>
  </div>
</template>
