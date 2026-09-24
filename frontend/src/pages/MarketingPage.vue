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
const form = reactive({ name: '', channel: 'social', budget_amount: '', status: 'draft' })

async function load() {
  rows.value = (await api<any[]>('/campaigns')).data
}

async function save() {
  try {
    await api('/campaigns', { method: 'POST', body: JSON.stringify({ ...form, budget_amount: form.budget_amount ? Number(form.budget_amount) : null }) })
    form.name = ''
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
    <p class="kicker">{{ t('navBusiness') }}</p>
    <h1 class="mt-2 text-3xl font-semibold">{{ t('marketing') }}</h1>
    <form v-if="auth.can('marketing.manage')" class="panel mt-6 grid gap-3 p-5 md:grid-cols-4" @submit.prevent="save">
      <label class="field md:col-span-2"><span>{{ t('name') }}</span><input v-model="form.name" required /></label>
      <label class="field"><span>{{ t('channel') }}</span>
        <select v-model="form.channel"><option value="social">social</option><option value="email">email</option><option value="ads">ads</option><option value="event">event</option></select>
      </label>
      <label class="field"><span>{{ t('amount') }}</span><input v-model="form.budget_amount" inputmode="numeric" /></label>
      <button class="btn btn-primary w-fit">{{ t('create') }}</button>
    </form>
    <div class="sheet mt-4">
      <table>
        <thead><tr><th>{{ t('name') }}</th><th>{{ t('channel') }}</th><th>{{ t('status') }}</th><th>{{ t('amount') }}</th></tr></thead>
        <tbody>
          <tr v-for="row in rows" :key="row.uuid">
            <td class="font-medium">{{ row.name }}</td>
            <td>{{ row.channel }}</td>
            <td><span class="badge">{{ row.status }}</span></td>
            <td>{{ row.budget_amount || '—' }} {{ row.currency }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
