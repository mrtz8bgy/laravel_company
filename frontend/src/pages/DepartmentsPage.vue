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
const people = ref<any[]>([])
const open = ref(false)
const editing = ref<string | null>(null)
const form = reactive({
  name: '',
  code: '',
  description: '',
  is_active: true,
  manager_uuid: '',
  parent_uuid: '',
})

async function load() {
  rows.value = (await api<any[]>('/departments')).data
  if (auth.can('users.view')) {
    people.value = (await api<any[]>('/users?per_page=100')).data
  }
}

function start(row?: any) {
  editing.value = row?.uuid ?? null
  form.name = row?.name ?? ''
  form.code = row?.code ?? ''
  form.description = row?.description ?? ''
  form.is_active = row?.is_active ?? true
  form.manager_uuid = row?.manager?.uuid ?? ''
  form.parent_uuid = row?.parent?.uuid ?? ''
  open.value = true
}

async function save() {
  try {
    const payload: Record<string, unknown> = {
      name: form.name,
      code: form.code || null,
      description: form.description,
      is_active: form.is_active,
    }
    if (auth.can('users.view')) payload.manager_uuid = form.manager_uuid || null
    payload.parent_uuid = form.parent_uuid || null

    if (editing.value) await api(`/departments/${editing.value}`, { method: 'PATCH', body: JSON.stringify(payload) })
    else await api('/departments', { method: 'POST', body: JSON.stringify(payload) })
    open.value = false
    ui.toast(t('save'))
    await load()
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

async function remove(uuid: string) {
  if (!confirm(t('delete'))) return
  try {
    await api(`/departments/${uuid}`, { method: 'DELETE' })
    await load()
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

onMounted(load)
</script>

<template>
  <div>
    <div class="mb-5 flex items-end justify-between gap-3">
      <div>
        <p class="text-sm text-copper">{{ t('organization') }}</p>
        <h1 class="text-3xl font-semibold">{{ t('departments') }}</h1>
      </div>
      <button v-if="auth.can('departments.create')" class="btn btn-primary" @click="start()">{{ t('create') }}</button>
    </div>
    <section class="panel p-5">
      <p v-if="!rows.length" class="text-muted">{{ t('empty') }}</p>
      <div v-for="row in rows" :key="row.uuid" class="table-row md:grid-cols-[1.4fr_.8fr_.6fr_auto]">
        <div>
          <p class="font-medium">{{ row.name }}</p>
          <p class="text-xs text-muted">{{ row.parent?.name || row.description }}</p>
        </div>
        <span class="text-sm">{{ row.manager?.name || '—' }}</span>
        <span class="text-sm">{{ row.teams_count }} {{ t('teams') }}</span>
        <div class="flex gap-2">
          <button v-if="auth.can('departments.update')" class="btn btn-ghost" @click="start(row)">{{ t('edit') }}</button>
          <button v-if="auth.can('departments.delete')" class="btn btn-danger" @click="remove(row.uuid)">{{ t('delete') }}</button>
        </div>
      </div>
    </section>
    <div v-if="open" class="fixed inset-0 z-50 flex items-center justify-center bg-ink/40 p-4" @click.self="open = false">
      <form class="panel max-h-[90vh] w-full max-w-lg overflow-auto p-6" @submit.prevent="save">
        <h2 class="mb-4 text-xl font-semibold">{{ editing ? t('edit') : t('create') }}</h2>
        <label class="field mb-3"><span>{{ t('name') }}</span><input v-model="form.name" required /></label>
        <label class="field mb-3"><span>{{ t('code') }}</span><input v-model="form.code" /></label>
        <label class="field mb-3">
          <span>{{ t('parent') }}</span>
          <select v-model="form.parent_uuid">
            <option value="">{{ t('none') }}</option>
            <option v-for="department in rows.filter((item) => item.uuid !== editing)" :key="department.uuid" :value="department.uuid">
              {{ department.name }}
            </option>
          </select>
        </label>
        <label v-if="auth.can('users.view')" class="field mb-3">
          <span>{{ t('manager') }}</span>
          <select v-model="form.manager_uuid">
            <option value="">{{ t('none') }}</option>
            <option v-for="person in people" :key="person.uuid" :value="person.uuid">{{ person.name }}</option>
          </select>
        </label>
        <label class="field mb-4"><span>{{ t('description') }}</span><textarea v-model="form.description" rows="3" /></label>
        <div class="flex justify-end gap-2">
          <button type="button" class="btn btn-ghost" @click="open = false">{{ t('cancel') }}</button>
          <button class="btn btn-primary">{{ t('save') }}</button>
        </div>
      </form>
    </div>
  </div>
</template>
