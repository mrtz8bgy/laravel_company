<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, ApiError } from '../api/client'
import { useDate } from '../lib/date'
import { useAuthStore } from '../stores/auth'
import { useUiStore } from '../stores/ui'

const auth = useAuthStore()
const ui = useUiStore()
const { t } = useI18n()
const rows = ref<any[]>([])
const form = reactive({ title: '', location: '', starts_at: '', ends_at: '', visibility: 'company' })

async function load() {
  rows.value = (await api<any[]>('/events')).data
}

async function save() {
  try {
    await api('/events', { method: 'POST', body: JSON.stringify(form) })
    ui.toast(t('save'))
    form.title = ''
    await load()
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

const { formatDateTime } = useDate()

function when(value?: string) {
  return value ? formatDateTime(value) : '—'
}

onMounted(load)
</script>

<template>
  <div>
    <p class="kicker">{{ t('navWork') }}</p>
    <h1 class="mt-2 text-3xl font-semibold">{{ t('calendar') }}</h1>
    <form v-if="auth.can('calendar.manage')" class="panel mt-6 grid gap-3 p-5 md:grid-cols-2" @submit.prevent="save">
      <label class="field md:col-span-2"><span>{{ t('name') }}</span><input v-model="form.title" required /></label>
      <label class="field"><span>{{ t('startsOn') }}</span><input v-model="form.starts_at" type="datetime-local" required /></label>
      <label class="field"><span>{{ t('endsOn') }}</span><input v-model="form.ends_at" type="datetime-local" required /></label>
      <label class="field"><span>{{ t('destination') }}</span><input v-model="form.location" /></label>
      <label class="field">
        <span>{{ t('visibility') }}</span>
        <select v-model="form.visibility">
          <option value="company">{{ t('visibility_company') }}</option>
          <option value="private">{{ t('visibility_private') }}</option>
        </select>
      </label>
      <button class="btn btn-primary w-fit">{{ t('create') }}</button>
    </form>
    <div class="sheet mt-4">
      <table>
        <thead><tr><th>{{ t('name') }}</th><th>{{ t('startsOn') }}</th><th>{{ t('destination') }}</th><th>{{ t('visibility') }}</th></tr></thead>
        <tbody>
          <tr v-for="row in rows" :key="row.uuid">
            <td class="font-medium">{{ row.title }}</td>
            <td>{{ when(row.starts_at) }}</td>
            <td>{{ row.location || '—' }}</td>
            <td><span class="badge">{{ t(`visibility_${row.visibility}`) }}</span></td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
