<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
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
const board = ref<any>(null)
const people = ref<any[]>([])
const form = reactive({ title: '', priority: 'normal', assignee_uuid: '', due_date: '', column_uuid: '' })
const memberUuid = ref('')

const columns = computed(() => board.value?.columns || [])
const { shortDate } = useDate()

const canAssign = computed(() => auth.can('tasks.assign') || auth.can('projects.update'))

async function load() {
  board.value = (await api<any>(`/projects/${route.params.uuid}/board`)).data
  form.column_uuid = board.value.columns?.[0]?.uuid || ''
  if (auth.can('users.view') && !people.value.length) {
    people.value = (await api<any[]>('/users')).data
  }
}

async function createTask() {
  try {
    await api('/tasks', {
      method: 'POST',
      body: JSON.stringify({
        project_uuid: route.params.uuid,
        column_uuid: form.column_uuid || undefined,
        title: form.title,
        priority: form.priority,
        assignee_uuid: form.assignee_uuid || null,
        due_date: form.due_date || null,
      }),
    })
    form.title = ''
    ui.toast(t('save'))
    await load()
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

async function move(taskUuid: string, columnUuid: string) {
  try {
    await api(`/tasks/${taskUuid}/move`, { method: 'POST', body: JSON.stringify({ column_uuid: columnUuid }) })
    await load()
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

async function addMember() {
  if (!memberUuid.value) return
  try {
    await api(`/projects/${route.params.uuid}/members`, {
      method: 'POST',
      body: JSON.stringify({ user_uuid: memberUuid.value, role: 'member' }),
    })
    memberUuid.value = ''
    ui.toast(t('save'))
    await load()
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

onMounted(load)
</script>

<template>
  <div>
    <p class="text-sm text-copper">{{ t('projects') }}</p>
    <div class="mt-1 flex flex-wrap items-end justify-between gap-3">
      <h1 class="text-3xl font-semibold">{{ board?.project?.name || t('loading') }}</h1>
      <router-link class="btn btn-ghost" to="/projects">{{ t('back') }}</router-link>
    </div>
    <p v-if="board?.project?.description" class="mt-2 max-w-2xl text-sm text-muted">{{ board.project.description }}</p>

    <form v-if="auth.can('tasks.create')" class="panel mt-5 grid gap-3 p-4 md:grid-cols-[1.4fr_.7fr_.8fr_.7fr_auto]" @submit.prevent="createTask">
      <label class="field"><span>{{ t('name') }}</span><input v-model="form.title" required maxlength="180" /></label>
      <label class="field">
        <span>{{ t('priority') }}</span>
        <select v-model="form.priority">
          <option value="low">{{ t('priority_low') }}</option>
          <option value="normal">{{ t('priority_normal') }}</option>
          <option value="high">{{ t('priority_high') }}</option>
          <option value="urgent">{{ t('priority_urgent') }}</option>
        </select>
      </label>
      <label class="field">
        <span>{{ t('column') }}</span>
        <select v-model="form.column_uuid">
          <option v-for="column in columns" :key="column.uuid" :value="column.uuid">{{ column.name }}</option>
        </select>
      </label>
      <label class="field"><span>{{ t('due') }}</span><JalaliDateInput v-model="form.due_date" /></label>
      <button class="btn btn-primary self-end">{{ t('create') }}</button>
    </form>

    <div class="mt-5 flex gap-3 overflow-x-auto pb-2">
      <section v-for="column in columns" :key="column.uuid" class="panel w-72 shrink-0 p-3">
        <div class="mb-3 flex items-center justify-between">
          <h2 class="font-semibold">{{ column.name }}</h2>
          <span class="badge">{{ column.tasks.length }}</span>
        </div>
        <article v-for="task in column.tasks" :key="task.uuid" class="mb-2 rounded-xl border border-line bg-paper p-3">
          <p class="font-medium">{{ task.title }}</p>
          <p class="mt-1 text-xs text-muted">{{ task.assignee?.name || t('none') }} · {{ task.due_date ? shortDate(task.due_date) : '—' }}</p>
          <p class="mt-1 text-xs text-copper">{{ t(`priority_${task.priority}`) }}</p>
          <label v-if="auth.can('tasks.update')" class="field mt-2">
            <span>{{ t('move') }}</span>
            <select :value="column.uuid" @change="move(task.uuid, ($event.target as HTMLSelectElement).value)">
              <option v-for="target in columns" :key="target.uuid" :value="target.uuid">{{ target.name }}</option>
            </select>
          </label>
        </article>
      </section>
    </div>

    <section v-if="canAssign" class="panel mt-4 p-4">
      <h2 class="font-semibold">{{ t('members') }}</h2>
      <ul class="mt-2 text-sm">
        <li v-for="member in board?.members || []" :key="member.user?.uuid">{{ member.user?.name }} · {{ member.role }}</li>
      </ul>
      <form class="mt-3 flex flex-wrap gap-2" @submit.prevent="addMember">
        <select v-model="memberUuid" class="min-w-48 rounded-xl border border-line bg-transparent px-3 py-2">
          <option value="">{{ t('assignee') }}</option>
          <option v-for="person in people" :key="person.uuid" :value="person.uuid">{{ person.name }}</option>
        </select>
        <button class="btn btn-ghost" :disabled="!memberUuid">{{ t('addMember') }}</button>
      </form>
    </section>
  </div>
</template>
