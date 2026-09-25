<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { api, ApiError } from '../api/client'
import JalaliDateInput from '../components/JalaliDateInput.vue'
import { useDate } from '../lib/date'
import { useAuthStore } from '../stores/auth'
import { useUiStore } from '../stores/ui'

const route = useRoute()
const auth = useAuthStore()
const ui = useUiStore()
const { t } = useI18n()
const { shortDate, weekdayName, duration, balance, today, shiftDays, localToIso } = useDate()

const uuid = computed(() => String(route.params.uuid))
const log = ref<any>(null)
const tasks = ref<any>(null)
const projects = ref<any[]>([])
const missing = ref(false)
const error = ref('')

const range = reactive({ from: '', to: '' })
const task = reactive({ project_uuid: '', title: '', description: '', priority: 'normal', due_date: '' })
const edit = reactive({ uuid: '', work_date: '', check_in: '', check_out: '', note: '' })

const canTasks = computed(() => auth.feature('projects') && auth.can('tasks.view'))
const canSend = computed(() => canTasks.value && auth.can('tasks.create'))
const canCorrect = computed(() => auth.feature('attendance') && auth.can('attendance.correct'))

const ranges = computed(() => {
  const to = today()

  return [
    { key: 'week', label: t('last7Days'), from: shiftDays(to, -6), to },
    { key: 'month', label: t('last30Days'), from: shiftDays(to, -29), to },
    { key: 'quarter', label: t('last90Days'), from: shiftDays(to, -89), to },
  ]
})

async function load() {
  try {
    const query = `?from=${range.from}&to=${range.to}`
    log.value = (await api<any>(`/attendance/people/${uuid.value}${query}`)).data
    missing.value = false
    error.value = ''
  } catch (caught) {
    log.value = null
    missing.value = true
    error.value = caught instanceof ApiError ? caught.message : t('empty')
  }

  if (canTasks.value) {
    tasks.value = (await api<any>(`/tasks/people/${uuid.value}`)).data
    if (canSend.value && !projects.value.length) projects.value = (await api<any[]>('/projects')).data
  }
}

function applyRange(preset: { from: string; to: string }) {
  range.from = preset.from
  range.to = preset.to
}

function openCorrection(day: any) {
  edit.uuid = day.uuid
  edit.work_date = day.work_date || ''
  edit.check_in = day.check_in_local || ''
  edit.check_out = day.check_out_local || ''
  edit.note = day.note || ''
}

async function saveCorrection() {
  try {
    const body: Record<string, unknown> = { note: edit.note || null }
    if (edit.check_in) body.check_in_at = localToIso(edit.workDate, edit.check_in)
    if (edit.check_out) body.check_out_at = localToIso(edit.workDate, edit.check_out)
    await api(`/attendance/days/${edit.uuid}`, { method: 'PATCH', body: JSON.stringify(body) })
    edit.uuid = ''
    ui.toast(t('save'))
    await load()
  } catch (caught) {
    ui.toast(caught instanceof ApiError ? caught.message : 'Error', 'bad')
  }
}

async function sendTask() {
  try {
    await api('/tasks', {
      method: 'POST',
      body: JSON.stringify({
        project_uuid: task.project_uuid,
        title: task.title,
        description: task.description || null,
        priority: task.priority,
        due_date: task.due_date || null,
        assignee_uuid: uuid.value,
      }),
    })
    task.title = ''
    task.description = ''
    task.due_date = ''
    ui.toast(t('taskSent'))
    await load()
  } catch (caught) {
    ui.toast(caught instanceof ApiError ? caught.message : 'Error', 'bad')
  }
}

watch(
  () => route.params.uuid,
  () => load(),
)

onMounted(async () => {
  range.to = today()
  range.from = shiftDays(range.to, -29)
  await load()
})
</script>

<template>
  <div>
    <p class="text-sm text-copper">{{ t('workReport') }}</p>
    <div class="mt-1 flex flex-wrap items-end justify-between gap-3">
      <h1 class="text-3xl font-semibold">{{ log?.user?.name || '…' }}</h1>
      <div class="flex flex-wrap items-center gap-2">
        <router-link class="btn btn-ghost" :to="`/people/${uuid}`">{{ t('personProfile') }}</router-link>
        <router-link class="btn btn-ghost" to="/people">{{ t('people') }}</router-link>
      </div>
    </div>
    <p v-if="log?.user" class="mt-2 text-sm text-muted">
      {{ log.user.job_title || '—' }} · {{ log.user.department?.name || t('none') }}
      <span v-if="log.user.employee_code"> · {{ log.user.employee_code }}</span>
    </p>

    <p v-if="missing" class="mt-8 text-sm text-danger">{{ error || t('empty') }}</p>

    <template v-else>
      <section class="panel mt-6 p-5">
        <div class="flex flex-wrap items-end justify-between gap-3">
          <div class="grid gap-3 sm:grid-cols-2">
            <label class="field"><span>{{ t('from') }}</span><JalaliDateInput v-model="range.from" /></label>
            <label class="field"><span>{{ t('to') }}</span><JalaliDateInput v-model="range.to" /></label>
          </div>
          <div class="flex flex-wrap gap-2">
            <button v-for="preset in ranges" :key="preset.key" class="btn btn-ghost" @click="applyRange(preset)">
              {{ preset.label }}
            </button>
            <button class="btn btn-primary" @click="load">{{ t('apply') }}</button>
          </div>
        </div>
      </section>

      <div v-if="log" class="mt-4 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <article class="panel p-4">
          <p class="text-sm text-muted">{{ t('workedHours') }}</p>
          <p class="mt-1 text-2xl font-semibold">{{ duration(log.summary?.worked_minutes) }}</p>
        </article>
        <article class="panel p-4">
          <p class="text-sm text-muted">{{ t('expectedHours') }}</p>
          <p class="mt-1 text-2xl font-semibold">{{ duration(log.summary?.expected_minutes) }}</p>
        </article>
        <article class="panel p-4">
          <p class="text-sm text-muted">{{ t('balance') }}</p>
          <p class="mt-1 text-2xl font-semibold">{{ balance(log.summary?.balance_minutes) }}</p>
        </article>
        <article class="panel p-4">
          <p class="text-sm text-muted">{{ t('late') }}</p>
          <p class="mt-1 text-2xl font-semibold">{{ duration(log.summary?.late_minutes) }}</p>
        </article>
      </div>

      <section v-if="log" class="panel mt-4 p-5">
        <div class="flex flex-wrap items-center justify-between gap-3">
          <h2 class="font-semibold">{{ t('workingHours') }}</h2>
          <span class="text-sm text-muted">
            {{ log.summary?.present_days ?? 0 }} / {{ log.summary?.days ?? 0 }} · {{ shortDate(log.range?.from) }} →
            {{ shortDate(log.range?.to) }}
          </span>
        </div>
        <p v-if="!log.days?.length" class="mt-4 text-sm text-muted">{{ t('empty') }}</p>
        <div v-else class="mt-3 space-y-2">
          <div
            v-for="day in log.days"
            :key="day.uuid"
            class="rounded-2xl border border-line px-3 py-3"
          >
            <div class="grid gap-2 md:grid-cols-[9rem_6rem_6rem_5rem_5rem_1fr] md:items-center">
              <div>
                <p class="font-medium">{{ shortDate(day.work_date) }}</p>
                <p class="text-xs text-muted">{{ weekdayName(day.work_date) }}</p>
              </div>
              <span class="text-sm">{{ day.check_in_local || '—' }}</span>
              <span class="text-sm">{{ day.check_out_local || '—' }}</span>
              <span class="text-sm">{{ duration(day.worked_minutes) }}</span>
              <span class="text-sm" :class="day.late_minutes ? 'text-danger' : 'text-muted'">
                {{ day.late_minutes ? duration(day.late_minutes) : '—' }}
              </span>
              <div class="flex flex-wrap items-center justify-end gap-2">
                <span class="badge">{{ t(`status_${day.location || 'off'}`) }}</span>
                <span v-if="day.excused" class="badge">{{ t('excused') }}</span>
                <button v-if="canCorrect" class="btn btn-ghost" @click="openCorrection(day)">
                  {{ t('correct') }}
                </button>
              </div>
            </div>
            <form
              v-if="canCorrect && edit.uuid === day.uuid"
              class="mt-3 grid gap-3 border-t border-line pt-3 md:grid-cols-[8rem_8rem_1fr_auto]"
              @submit.prevent="saveCorrection"
            >
              <label class="field"><span>{{ t('checkInAt') }}</span><input v-model="edit.check_in" placeholder="09:00" /></label>
              <label class="field"><span>{{ t('checkOutAt') }}</span><input v-model="edit.check_out" placeholder="17:00" /></label>
              <label class="field"><span>{{ t('note') }}</span><input v-model="edit.note" maxlength="500" /></label>
              <div class="flex items-end gap-2">
                <button class="btn btn-primary">{{ t('save') }}</button>
                <button type="button" class="btn btn-ghost" @click="edit.uuid = ''">{{ t('cancel') }}</button>
              </div>
            </form>
          </div>
        </div>
      </section>

      <section v-if="log" class="panel mt-4 p-5">
        <div class="flex flex-wrap items-center justify-between gap-3">
          <h2 class="font-semibold">{{ t('reports') }}</h2>
          <span class="text-sm text-muted">{{ log.summary?.reports ?? 0 }}</span>
        </div>
        <p v-if="!log.reports?.length" class="mt-4 text-sm text-muted">{{ t('noReports') }}</p>
        <article v-for="report in log.reports" :key="report.uuid" class="mt-3 rounded-2xl border border-line p-3">
          <div class="flex flex-wrap items-center justify-between gap-2">
            <span class="badge">{{ t(report.kind === 'morning' ? 'morningCheckin' : 'dailyReport') }}</span>
            <span class="text-xs text-muted">{{ shortDate(report.work_date) }} · {{ report.submitted_at?.slice(11, 16) }}</span>
          </div>
          <p class="mt-2 whitespace-pre-line text-sm">{{ report.body }}</p>
          <p v-if="report.blockers" class="mt-2 text-sm text-muted">{{ t('blockers') }}: {{ report.blockers }}</p>
        </article>
      </section>

      <section v-if="canTasks" class="panel mt-4 p-5">
        <div class="flex flex-wrap items-center justify-between gap-3">
          <h2 class="font-semibold">{{ t('assignedTasks') }}</h2>
          <span v-if="tasks?.summary" class="text-sm text-muted">
            {{ t('openTasks') }}: {{ tasks.summary.open }} · {{ t('done') }}: {{ tasks.summary.done }}
            <span v-if="tasks.summary.overdue" class="text-danger"> · {{ t('overdue') }}: {{ tasks.summary.overdue }}</span>
          </span>
        </div>
        <p v-if="!tasks?.tasks?.length" class="mt-4 text-sm text-muted">{{ t('noTasks') }}</p>
        <div v-else class="mt-3 space-y-2">
          <div
            v-for="row in tasks.tasks"
            :key="row.uuid"
            class="grid gap-2 rounded-2xl border border-line px-3 py-2 md:grid-cols-[1.4fr_.8fr_.6fr_.7fr_.6fr] md:items-center"
          >
            <p class="font-medium">{{ row.title }}</p>
            <span class="text-sm text-muted">{{ row.project?.name || '—' }}</span>
            <span class="badge">{{ t(`priority_${row.priority}`) }}</span>
            <span class="text-sm">{{ row.due_date ? shortDate(row.due_date) : '—' }}</span>
            <span class="badge" :class="row.column?.is_done ? '' : 'badge-open'">{{ row.column?.name || '—' }}</span>
          </div>
        </div>

        <form v-if="canSend" class="mt-5 grid gap-3 border-t border-line pt-4 md:grid-cols-2" @submit.prevent="sendTask">
          <h3 class="md:col-span-2 font-semibold">{{ t('sendTask') }}</h3>
          <label class="field">
            <span>{{ t('project') }}</span>
            <select v-model="task.project_uuid" required>
              <option value="" disabled>{{ t('selectProject') }}</option>
              <option v-for="project in projects" :key="project.uuid" :value="project.uuid">{{ project.name }}</option>
            </select>
          </label>
          <label class="field"><span>{{ t('due') }}</span><JalaliDateInput v-model="task.due_date" /></label>
          <label class="field md:col-span-2"><span>{{ t('name') }}</span><input v-model="task.title" required maxlength="180" /></label>
          <label class="field md:col-span-2"><span>{{ t('description') }}</span><textarea v-model="task.description" rows="3" maxlength="5000" /></label>
          <label class="field">
            <span>{{ t('priority') }}</span>
            <select v-model="task.priority">
              <option value="low">{{ t('priority_low') }}</option>
              <option value="normal">{{ t('priority_normal') }}</option>
              <option value="high">{{ t('priority_high') }}</option>
              <option value="urgent">{{ t('priority_urgent') }}</option>
            </select>
          </label>
          <button class="btn btn-primary self-end" :disabled="!task.project_uuid">{{ t('send') }}</button>
        </form>
      </section>
    </template>
  </div>
</template>
