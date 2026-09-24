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
const editing = ref<string | null>(null)
const form = reactive({ name: '', description: '', department_uuid: '', is_active: true })

async function load() {
  rows.value = (await api<any[]>('/teams')).data
  if (auth.can('departments.view')) departments.value = (await api<any[]>('/departments')).data
}

function start(row?: any) {
  editing.value = row?.uuid ?? null
  form.name = row?.name ?? ''
  form.description = row?.description ?? ''
  form.department_uuid = row?.department?.uuid ?? departments.value[0]?.uuid ?? ''
  form.is_active = row?.is_active ?? true
  open.value = true
}

async function save() {
  try {
    const payload = { ...form }
    if (editing.value) await api(`/teams/${editing.value}`, { method: 'PATCH', body: JSON.stringify(payload) })
    else await api('/teams', { method: 'POST', body: JSON.stringify(payload) })
    open.value = false
    ui.toast(t('save'))
    await load()
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

async function remove(uuid: string) {
  if (!confirm(t('delete'))) return
  await api(`/teams/${uuid}`, { method: 'DELETE' })
  await load()
}

onMounted(load)
</script>

<template>
  <div>
    <div class="mb-5 flex items-end justify-between">
      <div>
        <p class="text-sm text-copper">{{ t('organization') }}</p>
        <h1 class="text-3xl font-semibold">{{ t('teams') }}</h1>
      </div>
      <button v-if="auth.can('teams.create')" class="btn btn-primary" @click="start()">{{ t('create') }}</button>
    </div>
    <section class="panel p-5">
      <p v-if="!rows.length" class="text-muted">{{ t('empty') }}</p>
      <div v-for="row in rows" :key="row.uuid" class="table-row md:grid-cols-[1.3fr_1fr_.5fr_auto]">
        <p class="font-medium">{{ row.name }}</p>
        <p class="text-sm text-muted">{{ row.department?.name }}</p>
        <p class="text-sm">{{ row.members_count }} {{ t('members') }}</p>
        <div class="flex gap-2">
          <button v-if="auth.can('teams.update')" class="btn btn-ghost" @click="start(row)">{{ t('edit') }}</button>
          <button v-if="auth.can('teams.delete')" class="btn btn-danger" @click="remove(row.uuid)">{{ t('delete') }}</button>
        </div>
      </div>
    </section>
    <div v-if="open" class="fixed inset-0 z-50 flex items-center justify-center bg-ink/40 p-4" @click.self="open = false">
      <form class="panel w-full max-w-lg p-6" @submit.prevent="save">
        <h2 class="mb-4 text-xl font-semibold">{{ editing ? t('edit') : t('create') }}</h2>
        <label class="field mb-3"><span>{{ t('name') }}</span><input v-model="form.name" required /></label>
        <label class="field mb-3">
          <span>{{ t('department') }}</span>
          <select v-model="form.department_uuid" required>
            <option v-for="department in departments" :key="department.uuid" :value="department.uuid">{{ department.name }}</option>
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
