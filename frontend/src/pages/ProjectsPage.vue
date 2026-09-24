<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, ApiError } from '../api/client'
import { useAuthStore } from '../stores/auth'
import { useUiStore } from '../stores/ui'

const auth = useAuthStore()
const ui = useUiStore()
const { t } = useI18n()
const rows = ref<any[]>([])
const departments = ref<any[]>([])
const open = ref(false)
const form = reactive({ name: '', description: '', visibility: 'company', department_uuid: '', due_date: '' })

async function load() {
  rows.value = (await api<any[]>('/projects')).data
  if (auth.can('departments.view')) departments.value = (await api<any[]>('/departments')).data
}

async function save() {
  try {
    const payload: Record<string, string> = {
      name: form.name,
      visibility: form.visibility,
    }
    if (form.description) payload.description = form.description
    if (form.department_uuid) payload.department_uuid = form.department_uuid
    if (form.due_date) payload.due_date = form.due_date
    await api('/projects', { method: 'POST', body: JSON.stringify(payload) })
    open.value = false
    form.name = ''
    form.description = ''
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
    <div class="mb-5 flex flex-wrap items-end justify-between gap-3">
      <div>
        <p class="text-sm text-copper">{{ t('board') }}</p>
        <h1 class="text-3xl font-semibold">{{ t('projects') }}</h1>
      </div>
      <button v-if="auth.can('projects.create')" class="btn btn-primary" @click="open = true">{{ t('create') }}</button>
    </div>
    <p v-if="!rows.length" class="text-sm text-muted">{{ t('empty') }}</p>
    <div class="grid gap-3 sm:grid-cols-2">
      <router-link v-for="row in rows" :key="row.uuid" class="panel p-5 hover:border-copper" :to="`/projects/${row.uuid}`">
        <div class="flex items-start justify-between gap-3">
          <div>
            <h2 class="text-lg font-semibold">{{ row.name }}</h2>
            <p class="mt-1 text-sm text-muted">{{ row.code || row.slug }}</p>
          </div>
          <span class="badge">{{ t(`visibility_${row.visibility}`) }}</span>
        </div>
        <p v-if="row.description" class="mt-3 line-clamp-2 text-sm">{{ row.description }}</p>
        <p class="mt-4 text-xs text-muted">{{ row.tasks_count ?? 0 }} · {{ row.due_date || '—' }}</p>
      </router-link>
    </div>

    <div v-if="open" class="fixed inset-0 z-50 flex items-end justify-center bg-ink/40 p-4 sm:items-center" @click.self="open = false">
      <form class="panel w-full max-w-lg p-5" @submit.prevent="save">
        <h2 class="text-lg font-semibold">{{ t('create') }}</h2>
        <label class="field mt-3"><span>{{ t('name') }}</span><input v-model="form.name" required maxlength="160" /></label>
        <label class="field mt-3"><span>{{ t('description') }}</span><textarea v-model="form.description" rows="3" /></label>
        <label class="field mt-3">
          <span>{{ t('visibility') }}</span>
          <select v-model="form.visibility">
            <option value="company">{{ t('visibility_company') }}</option>
            <option value="private">{{ t('visibility_private') }}</option>
          </select>
        </label>
        <label v-if="departments.length" class="field mt-3">
          <span>{{ t('department') }}</span>
          <select v-model="form.department_uuid">
            <option value="">{{ t('none') }}</option>
            <option v-for="department in departments" :key="department.uuid" :value="department.uuid">{{ department.name }}</option>
          </select>
        </label>
        <label class="field mt-3"><span>{{ t('due') }}</span><input v-model="form.due_date" type="date" /></label>
        <div class="mt-4 flex gap-2">
          <button class="btn btn-primary">{{ t('save') }}</button>
          <button type="button" class="btn btn-ghost" @click="open = false">{{ t('cancel') }}</button>
        </div>
      </form>
    </div>
  </div>
</template>
