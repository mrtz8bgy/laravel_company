<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api } from '../api/client'
import { useAuthStore } from '../stores/auth'

const auth = useAuthStore()
const { t } = useI18n()
const data = ref<any>(null)

const greeting = computed(() => {
  const zone = auth.company?.timezone || 'Asia/Tehran'
  const hour = Number(new Intl.DateTimeFormat('en-GB', { hour: 'numeric', hourCycle: 'h23', timeZone: zone }).format(new Date()))
  if (hour < 12) return t('greetingMorning')
  if (hour < 17) return t('greetingNoon')
  if (hour < 21) return t('greetingEvening')
  return t('greetingNight')
})

const labels: Record<string, string> = {
  employees: t('employees'),
  departments: t('departments'),
  teams: t('teams'),
  pending_invitations: t('pendingInvites'),
  late_minutes: t('late'),
  worked_minutes: t('worked'),
  present_today: t('presentToday'),
}

onMounted(async () => {
  data.value = (await api<any>('/dashboard')).data
})
</script>

<template>
  <div>
    <p class="text-sm text-copper">{{ auth.company?.name }}</p>
    <h1 class="mt-1 text-3xl font-semibold">{{ greeting }}، {{ auth.user?.name }}</h1>
    <p class="mt-2 max-w-2xl text-muted">{{ t('principle2') }}</p>
    <div v-if="!data" class="mt-8 text-muted">{{ t('loading') }}</div>
    <div v-else class="mt-8 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
      <article v-for="widget in data.widgets" :key="widget.key" class="panel stat">
        <p class="text-sm text-muted">{{ labels[widget.key] || widget.key }}</p>
        <strong>{{ widget.value }}</strong>
      </article>
    </div>
    <div class="mt-6 grid gap-4 lg:grid-cols-[1.3fr_.7fr]">
      <section class="panel p-5">
        <h2 class="font-semibold">{{ t('recent') }}</h2>
        <p v-if="!data?.recent_activity?.length" class="mt-6 text-sm text-muted">{{ t('empty') }}</p>
        <div v-for="item in data?.recent_activity || []" :key="item.id" class="table-row grid-cols-[auto_1fr_auto]">
          <span class="badge">{{ item.action }}</span>
          <span class="text-sm">{{ item.user?.name || '—' }} <span class="text-muted">{{ item.entity_type }}</span></span>
          <span class="text-xs text-muted">{{ item.created_at?.slice(0, 16).replace('T', ' ') }}</span>
        </div>
      </section>
      <section class="panel p-5">
        <h2 class="font-semibold">{{ t('quick') }}</h2>
        <div class="mt-4 grid gap-2">
          <router-link v-if="auth.feature('attendance') && auth.can('attendance.clock')" class="btn btn-primary" to="/attendance">{{ t('attendance') }}</router-link>
          <router-link v-if="auth.feature('projects') && auth.can('projects.view')" class="btn btn-ghost" to="/projects">{{ t('projects') }}</router-link>
          <router-link v-if="auth.feature('communication') && auth.can('messages.view')" class="btn btn-ghost" to="/inbox">{{ t('inbox') }}</router-link>
          <router-link v-if="auth.feature('crm') && auth.can('crm.view')" class="btn btn-ghost" to="/crm">{{ t('crm') }}</router-link>
          <router-link v-if="auth.feature('finance') && auth.can('finance.view')" class="btn btn-ghost" to="/finance">{{ t('finance') }}</router-link>
          <router-link v-if="auth.feature('analytics') && auth.can('analytics.view')" class="btn btn-ghost" to="/analytics">{{ t('analytics') }}</router-link>
          <router-link class="btn btn-ghost" to="/people">{{ t('people') }}</router-link>
        </div>
        <div v-if="data?.attendance?.tasks_available" class="mt-4 space-y-2">
          <p class="text-sm font-medium">{{ t('tasksToday') }}</p>
          <p v-if="!data.attendance.tasks?.length" class="text-sm text-muted">{{ t('noTasks') }}</p>
          <router-link v-for="task in data.attendance.tasks" :key="task.uuid" class="block text-sm" :to="`/projects/${task.project?.uuid}`">
            {{ task.title }}
          </router-link>
        </div>
        <p v-else-if="data?.attendance" class="mt-4 text-sm text-muted">{{ t('tasksLater') }}</p>
      </section>
    </div>
  </div>
</template>
