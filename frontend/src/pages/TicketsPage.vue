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
const form = reactive({ subject: '', body: '', priority: 'normal' })

async function load() {
  rows.value = (await api<any[]>('/tickets')).data
}

async function save() {
  try {
    await api('/tickets', { method: 'POST', body: JSON.stringify(form) })
    form.subject = ''
    form.body = ''
    ui.toast(t('save'))
    await load()
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

async function close(uuid: string) {
  await api(`/tickets/${uuid}`, { method: 'PATCH', body: JSON.stringify({ status: 'resolved' }) })
  await load()
}

onMounted(load)
</script>

<template>
  <div>
    <p class="kicker">{{ t('navBusiness') }}</p>
    <h1 class="mt-2 text-3xl font-semibold">{{ t('tickets') }}</h1>
    <form class="panel mt-6 grid gap-3 p-5" @submit.prevent="save">
      <label class="field"><span>{{ t('subject') }}</span><input v-model="form.subject" required /></label>
      <label class="field"><span>{{ t('description') }}</span><textarea v-model="form.body" rows="3" required /></label>
      <button class="btn btn-primary w-fit">{{ t('submit') }}</button>
    </form>
    <div class="sheet mt-4">
      <table>
        <thead><tr><th>{{ t('subject') }}</th><th>{{ t('people') }}</th><th>{{ t('priority') }}</th><th>{{ t('status') }}</th><th></th></tr></thead>
        <tbody>
          <tr v-for="row in rows" :key="row.uuid">
            <td class="font-medium">{{ row.subject }}</td>
            <td>{{ row.requester?.name || '—' }}</td>
            <td>{{ t(`priority_${row.priority}`) }}</td>
            <td><span class="badge">{{ row.status }}</span></td>
            <td><button v-if="auth.can('tickets.manage') && row.status === 'open'" class="btn btn-ghost" @click="close(row.uuid)">{{ t('approve') }}</button></td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
