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
const form = reactive({ title: '', note: '', kind: 'general' })

async function load() {
  rows.value = (await api<any[]>('/approvals')).data
}

async function save() {
  try {
    await api('/approvals', { method: 'POST', body: JSON.stringify(form) })
    form.title = ''
    await load()
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

async function review(uuid: string, decision: 'approved' | 'rejected') {
  try {
    await api(`/approvals/${uuid}/review`, { method: 'POST', body: JSON.stringify({ decision }) })
    await load()
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

onMounted(load)
</script>

<template>
  <div>
    <p class="kicker">{{ t('navBusiness') }}</p>
    <h1 class="mt-2 text-3xl font-semibold">{{ t('approvals') }}</h1>
    <form class="panel mt-6 grid gap-3 p-5 md:grid-cols-[1fr_1fr_auto]" @submit.prevent="save">
      <label class="field"><span>{{ t('name') }}</span><input v-model="form.title" required /></label>
      <label class="field"><span>{{ t('note') }}</span><input v-model="form.note" /></label>
      <button class="btn btn-primary self-end">{{ t('submit') }}</button>
    </form>
    <div class="sheet mt-4">
      <table>
        <thead><tr><th>{{ t('name') }}</th><th>{{ t('people') }}</th><th>{{ t('status') }}</th><th></th></tr></thead>
        <tbody>
          <tr v-for="row in rows" :key="row.uuid">
            <td>
              <p class="font-medium">{{ row.title }}</p>
              <p class="text-xs text-muted">{{ row.note }}</p>
            </td>
            <td>{{ row.requester?.name || '—' }}</td>
            <td><span class="badge">{{ t(`request_${row.status}`) }}</span></td>
            <td>
              <div v-if="auth.can('workflows.review') && row.status === 'pending' && row.requester?.uuid !== auth.user?.uuid" class="flex gap-2">
                <button class="btn btn-primary" @click="review(row.uuid, 'approved')">{{ t('approve') }}</button>
                <button class="btn btn-ghost" @click="review(row.uuid, 'rejected')">{{ t('reject') }}</button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
