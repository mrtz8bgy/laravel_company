<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, ApiError } from '../api/client'
import { useUiStore } from '../stores/ui'

const ui = useUiStore()
const { t } = useI18n()
const today = ref<any>(null)
const note = ref('')
const morning = reactive({ body: '' })
const daily = reactive({ body: '', blockers: '' })

const statusKey = computed(() => `status_${today.value?.presence?.status || 'off'}`)
const checkedIn = computed(() => Boolean(today.value?.day?.check_in_at) && !today.value?.day?.check_out_at)
const onBreak = computed(() => today.value?.presence?.status === 'break')

async function load() {
  today.value = (await api<any>('/attendance/today')).data
  morning.body = today.value.reports?.morning?.body || ''
  daily.body = today.value.reports?.daily?.body || ''
  daily.blockers = today.value.reports?.daily?.blockers || ''
}

async function act(path: string, body?: Record<string, unknown>) {
  try {
    await api(path, { method: path.includes('status') ? 'PUT' : 'POST', body: JSON.stringify(body ?? {}) })
    note.value = ''
    ui.toast(t('save'))
    await load()
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

async function saveReport(kind: 'morning' | 'daily') {
  const payload = kind === 'morning'
    ? { kind, body: morning.body }
    : { kind, body: daily.body, blockers: daily.blockers || null }
  await act('/attendance/reports', payload)
}

onMounted(load)
</script>

<template>
  <div>
    <p class="text-sm text-copper">{{ t('virtualOffice') }}</p>
    <div class="mt-1 flex flex-wrap items-end justify-between gap-3">
      <h1 class="text-3xl font-semibold">{{ t('attendance') }}</h1>
      <span class="badge">{{ today?.is_working_day ? t('workingToday') : t('dayOff') }}</span>
    </div>
    <p v-if="today?.schedule" class="mt-2 text-sm text-muted">
      {{ today.schedule.start_time }} – {{ today.schedule.end_time }}
      · {{ t('grace') }} {{ today.schedule.grace_minutes }}
    </p>

    <section class="panel mt-6 p-5">
      <div class="flex flex-wrap items-center justify-between gap-3">
        <div>
          <p class="text-sm text-muted">{{ t('presence') }}</p>
          <p class="text-2xl font-semibold">{{ t(statusKey) }}</p>
          <p v-if="today?.day" class="mt-1 text-sm text-muted">
            {{ today.day.check_in_local || '—' }} → {{ today.day.check_out_local || '…' }}
          </p>
        </div>
        <div class="grid grid-cols-3 gap-3 text-center">
          <div>
            <p class="text-xs text-muted">{{ t('late') }}</p>
            <p class="text-xl font-semibold">{{ today?.day?.late_minutes ?? 0 }}</p>
          </div>
          <div>
            <p class="text-xs text-muted">{{ t('worked') }}</p>
            <p class="text-xl font-semibold">{{ today?.day?.worked_minutes ?? 0 }}</p>
          </div>
          <div>
            <p class="text-xs text-muted">{{ t('break') }}</p>
            <p class="text-xl font-semibold">{{ today?.day?.break_minutes ?? 0 }}</p>
          </div>
        </div>
      </div>
      <label class="field mt-4"><span>{{ t('note') }}</span><input v-model="note" maxlength="500" /></label>
      <div class="mt-4 flex flex-wrap gap-2">
        <button class="btn btn-primary" :disabled="checkedIn" @click="act('/attendance/check-in', { location: 'office', note })">{{ t('checkInOffice') }}</button>
        <button class="btn btn-ghost" :disabled="checkedIn" @click="act('/attendance/check-in', { location: 'remote', note })">{{ t('checkInRemote') }}</button>
        <button class="btn btn-ghost" :disabled="!checkedIn || onBreak" @click="act('/attendance/break/start', { note })">{{ t('startBreak') }}</button>
        <button class="btn btn-ghost" :disabled="!onBreak" @click="act('/attendance/break/end', { note })">{{ t('endBreak') }}</button>
        <button class="btn btn-danger" :disabled="!checkedIn" @click="act('/attendance/check-out', { note })">{{ t('checkOut') }}</button>
      </div>
      <div class="mt-3 flex flex-wrap gap-2">
        <button v-for="status in ['meeting', 'mission', 'leave']" :key="status" class="btn btn-ghost" @click="act('/attendance/status', { status, note })">
          {{ t(`status_${status}`) }}
        </button>
      </div>
    </section>

    <div class="mt-4 grid gap-4 lg:grid-cols-2">
      <form class="panel p-5" @submit.prevent="saveReport('morning')">
        <h2 class="font-semibold">{{ t('morningCheckin') }}</h2>
        <label class="field mt-3"><span>{{ t('description') }}</span><textarea v-model="morning.body" rows="4" required minlength="3" /></label>
        <button class="btn btn-primary mt-3">{{ t('submit') }}</button>
      </form>
      <form class="panel p-5" @submit.prevent="saveReport('daily')">
        <h2 class="font-semibold">{{ t('dailyReport') }}</h2>
        <label class="field mt-3"><span>{{ t('description') }}</span><textarea v-model="daily.body" rows="4" required minlength="3" /></label>
        <label class="field mt-3"><span>{{ t('blockers') }}</span><textarea v-model="daily.blockers" rows="2" /></label>
        <button class="btn btn-primary mt-3">{{ t('submit') }}</button>
      </form>
    </div>

    <section class="panel mt-4 p-5">
      <h2 class="font-semibold">{{ t('tasksToday') }}</h2>
      <p v-if="!today?.tasks_available" class="mt-3 text-sm text-muted">{{ t('tasksLater') }}</p>
      <p v-else-if="!today.tasks?.length" class="mt-3 text-sm text-muted">{{ t('noTasks') }}</p>
      <div v-else class="mt-3 space-y-2">
        <router-link
          v-for="task in today.tasks"
          :key="task.uuid"
          class="flex items-center justify-between rounded-xl border border-line px-3 py-2 hover:bg-paper"
          :to="task.project ? `/projects/${task.project.uuid}` : '/projects'"
        >
          <span>
            <span class="font-medium">{{ task.title }}</span>
            <span class="ms-2 text-xs text-muted">{{ task.project?.name }}</span>
          </span>
          <span class="badge">{{ t(`priority_${task.priority}`) }}</span>
        </router-link>
      </div>
    </section>
  </div>
</template>
