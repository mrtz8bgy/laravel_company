<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, ApiError } from '../api/client'
import { useAuthStore } from '../stores/auth'
import { useUiStore } from '../stores/ui'

const auth = useAuthStore()
const ui = useUiStore()
const { t } = useI18n()
const accounts = ref<any[]>([])
const deals = ref<any[]>([])
const account = reactive({ name: '' })
const deal = reactive({ title: '', amount: '', stage: 'lead' })

async function load() {
  accounts.value = (await api<any[]>('/crm/accounts')).data
  deals.value = (await api<any[]>('/crm/deals')).data
}

async function saveAccount() {
  try {
    await api('/crm/accounts', { method: 'POST', body: JSON.stringify(account) })
    account.name = ''
    await load()
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

async function saveDeal() {
  try {
    await api('/crm/deals', { method: 'POST', body: JSON.stringify({ ...deal, amount: deal.amount ? Number(deal.amount) : 0 }) })
    deal.title = ''
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
    <h1 class="mt-2 text-3xl font-semibold">{{ t('crm') }}</h1>
    <div class="mt-6 grid gap-4 lg:grid-cols-2">
      <section class="panel p-5">
        <h2 class="font-semibold">{{ t('accounts') }}</h2>
        <form v-if="auth.can('crm.manage')" class="mt-3 flex gap-2" @submit.prevent="saveAccount">
          <input v-model="account.name" class="input" required :placeholder="t('name')" />
          <button class="btn btn-primary">{{ t('create') }}</button>
        </form>
        <div class="sheet mt-4">
          <table>
            <thead><tr><th>{{ t('name') }}</th><th>{{ t('status') }}</th></tr></thead>
            <tbody><tr v-for="row in accounts" :key="row.uuid"><td>{{ row.name }}</td><td><span class="badge">{{ row.status }}</span></td></tr></tbody>
          </table>
        </div>
      </section>
      <section class="panel p-5">
        <h2 class="font-semibold">{{ t('deals') }}</h2>
        <form v-if="auth.can('crm.manage')" class="mt-3 grid gap-2" @submit.prevent="saveDeal">
          <input v-model="deal.title" class="input" required :placeholder="t('name')" />
          <input v-model="deal.amount" class="input" inputmode="numeric" :placeholder="t('amount')" />
          <button class="btn btn-primary w-fit">{{ t('create') }}</button>
        </form>
        <div class="sheet mt-4">
          <table>
            <thead><tr><th>{{ t('name') }}</th><th>{{ t('stage') }}</th><th>{{ t('amount') }}</th></tr></thead>
            <tbody>
              <tr v-for="row in deals" :key="row.uuid">
                <td>{{ row.title }}</td>
                <td><span class="badge">{{ row.stage }}</span></td>
                <td>{{ row.amount }} {{ row.currency }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>
    </div>
  </div>
</template>
