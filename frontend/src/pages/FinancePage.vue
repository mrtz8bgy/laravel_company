<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, ApiError } from '../api/client'
import { useAuthStore } from '../stores/auth'
import { useUiStore } from '../stores/ui'

const auth = useAuthStore()
const ui = useUiStore()
const { t } = useI18n()
const invoices = ref<any[]>([])
const expenses = ref<any[]>([])
const invoice = reactive({ number: '', party_name: '', amount: '', status: 'draft' })
const expense = reactive({ category: '', amount: '', note: '' })

async function load() {
  invoices.value = (await api<any[]>('/finance/invoices')).data
  expenses.value = (await api<any[]>('/finance/expenses')).data
}

async function saveInvoice() {
  try {
    await api('/finance/invoices', { method: 'POST', body: JSON.stringify({ ...invoice, amount: Number(invoice.amount) }) })
    invoice.number = ''
    await load()
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

async function saveExpense() {
  try {
    await api('/finance/expenses', { method: 'POST', body: JSON.stringify({ ...expense, amount: Number(expense.amount) }) })
    expense.category = ''
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
    <h1 class="mt-2 text-3xl font-semibold">{{ t('finance') }}</h1>
    <p class="mt-2 text-sm text-muted">{{ t('sensitiveHidden') }}</p>
    <div class="mt-6 grid gap-4 lg:grid-cols-2">
      <section class="panel p-5">
        <h2 class="font-semibold">{{ t('invoices') }}</h2>
        <form v-if="auth.can('finance.manage')" class="mt-3 grid gap-2" @submit.prevent="saveInvoice">
          <input v-model="invoice.number" class="input" required :placeholder="t('code')" />
          <input v-model="invoice.party_name" class="input" required :placeholder="t('party')" />
          <input v-model="invoice.amount" class="input" required inputmode="numeric" :placeholder="t('amount')" />
          <button class="btn btn-primary w-fit">{{ t('create') }}</button>
        </form>
        <div class="sheet mt-4">
          <table>
            <thead><tr><th>{{ t('code') }}</th><th>{{ t('party') }}</th><th>{{ t('amount') }}</th><th>{{ t('status') }}</th></tr></thead>
            <tbody>
              <tr v-for="row in invoices" :key="row.uuid">
                <td>{{ row.number }}</td><td>{{ row.party_name }}</td><td>{{ row.amount }}</td><td><span class="badge">{{ row.status }}</span></td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>
      <section class="panel p-5">
        <h2 class="font-semibold">{{ t('expenses') }}</h2>
        <form v-if="auth.can('finance.manage')" class="mt-3 grid gap-2" @submit.prevent="saveExpense">
          <input v-model="expense.category" class="input" required :placeholder="t('name')" />
          <input v-model="expense.amount" class="input" required inputmode="numeric" :placeholder="t('amount')" />
          <button class="btn btn-primary w-fit">{{ t('create') }}</button>
        </form>
        <div class="sheet mt-4">
          <table>
            <thead><tr><th>{{ t('name') }}</th><th>{{ t('amount') }}</th></tr></thead>
            <tbody><tr v-for="row in expenses" :key="row.uuid"><td>{{ row.category }}</td><td>{{ row.amount }} {{ row.currency }}</td></tr></tbody>
          </table>
        </div>
      </section>
    </div>
  </div>
</template>
