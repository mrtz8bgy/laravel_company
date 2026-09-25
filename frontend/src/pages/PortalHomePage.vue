<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, ApiError } from '../api/client'
import { useUiStore } from '../stores/ui'

type Customer = {
  uuid: string
  status: string
  organization_name?: string | null
  phone?: string | null
  review_note?: string | null
  user?: { name: string; email: string; phone?: string | null }
}

const ui = useUiStore()
const { t } = useI18n()
const customer = ref<Customer | null>(null)
const summary = ref({ orders: 0, open_threads: 0, open_tickets: 0 })
const name = ref('')
const phone = ref('')
const organization = ref('')
const loading = ref(false)

async function load() {
  const response = await api<{ customer: Customer; summary: { orders: number; open_threads: number; open_tickets: number } }>('/portal/me')
  customer.value = response.data.customer
  summary.value = response.data.summary
  name.value = response.data.customer.user?.name || ''
  phone.value = response.data.customer.phone || response.data.customer.user?.phone || ''
  organization.value = response.data.customer.organization_name || ''
}

onMounted(load)

async function save() {
  loading.value = true
  try {
    const response = await api<Customer>('/portal/me', {
      method: 'PATCH',
      body: JSON.stringify({ name: name.value, phone: phone.value || null, organization_name: organization.value || null }),
    })
    customer.value = { ...customer.value, ...response.data }
    ui.toast(response.message || t('save'))
  } catch (err) {
    ui.toast(err instanceof ApiError ? err.message : 'Error', 'bad')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div v-if="customer" class="grid gap-5">
    <section class="panel p-6">
      <p class="kicker">{{ t('personalPage') }}</p>
      <div class="mt-3 flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 class="text-3xl font-semibold">{{ customer.user?.name }}</h1>
          <p class="mt-1 text-sm text-muted">{{ customer.user?.email }}</p>
        </div>
        <span class="badge" :class="customer.status === 'active' ? 'badge-open' : customer.status === 'rejected' ? 'badge-danger' : ''">
          {{ t('status_' + customer.status) }}
        </span>
      </div>
      <p v-if="customer.status === 'pending'" class="mt-4 rounded-2xl bg-copper-soft px-4 py-3 text-sm">{{ t('awaitingApproval') }}</p>
      <p v-else-if="customer.status === 'rejected'" class="mt-4 rounded-2xl bg-danger-soft px-4 py-3 text-sm text-danger">
        {{ t('registrationRejected') }} <span v-if="customer.review_note">{{ customer.review_note }}</span>
      </p>
      <div class="mt-5 grid gap-3 sm:grid-cols-2">
        <div class="rounded-2xl border border-line px-4 py-3">
          <p class="text-xs text-muted">{{ t('myOrders') }}</p>
          <p class="mt-1 text-2xl font-semibold">{{ summary.orders }}</p>
        </div>
        <div class="rounded-2xl border border-line px-4 py-3">
          <p class="text-xs text-muted">{{ t('myMessages') }}</p>
          <p class="mt-1 text-2xl font-semibold">{{ summary.open_threads }}</p>
        </div>
        <div class="rounded-2xl border border-line px-4 py-3">
          <p class="text-xs text-muted">{{ t('myTickets') }}</p>
          <p class="mt-1 text-2xl font-semibold">{{ summary.open_tickets }}</p>
        </div>
      </div>
      <router-link class="btn btn-ghost mt-4" to="/portal/profile">{{ t('myProfile') }}</router-link>
    </section>
    <form class="panel p-6" @submit.prevent="save">
      <h2 class="font-semibold">{{ t('profile') }}</h2>
      <p class="mt-1 text-xs text-muted">{{ t('emailLocked') }}</p>
      <div class="mt-4 grid gap-3 sm:grid-cols-2">
        <label class="field"><span>{{ t('name') }}</span><input v-model="name" required /></label>
        <label class="field"><span>{{ t('phone') }}</span><input v-model="phone" /></label>
        <label class="field sm:col-span-2"><span>{{ t('organizationName') }}</span><input v-model="organization" /></label>
      </div>
      <button class="btn btn-primary mt-4" :disabled="loading">{{ t('save') }}</button>
    </form>
  </div>
</template>
