<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, ApiError } from '../api/client'
import { useUiStore } from '../stores/ui'

type Customer = {
  status: string
  organization_name?: string | null
  phone?: string | null
  note?: string | null
  review_note?: string | null
  created_at?: string | null
  user?: { name: string; email: string }
}

const ui = useUiStore()
const { t } = useI18n()
const customer = ref<Customer | null>(null)
const name = ref('')
const phone = ref('')
const organization = ref('')
const note = ref('')
const loading = ref(false)

async function load() {
  const response = await api<{ customer: Customer }>('/portal/me')
  customer.value = response.data.customer
  name.value = response.data.customer.user?.name || ''
  phone.value = response.data.customer.phone || ''
  organization.value = response.data.customer.organization_name || ''
  note.value = response.data.customer.note || ''
}

onMounted(load)

async function save() {
  loading.value = true
  try {
    const response = await api<Customer>('/portal/me', {
      method: 'PATCH',
      body: JSON.stringify({
        name: name.value,
        phone: phone.value || null,
        organization_name: organization.value || null,
        note: note.value || null,
      }),
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
  <form v-if="customer" class="panel mx-auto max-w-2xl p-6" @submit.prevent="save">
    <p class="kicker">{{ t('customerPortal') }}</p>
    <div class="mt-2 flex flex-wrap items-end justify-between gap-3">
      <h1 class="text-3xl font-semibold">{{ t('myProfile') }}</h1>
      <span class="badge" :class="customer.status === 'active' ? 'badge-open' : customer.status === 'rejected' ? 'badge-danger' : ''">
        {{ t('status_' + customer.status) }}
      </span>
    </div>
    <p class="mt-2 text-sm text-muted">{{ t('emailLocked') }}</p>
    <p v-if="customer.status === 'pending'" class="mt-4 rounded-2xl bg-copper-soft px-4 py-3 text-sm">{{ t('awaitingApproval') }}</p>
    <p v-else-if="customer.status === 'rejected'" class="mt-4 rounded-2xl bg-danger-soft px-4 py-3 text-sm text-danger">
      {{ t('registrationRejected') }} {{ customer.review_note }}
    </p>
    <div class="mt-5 grid gap-3 sm:grid-cols-2">
      <label class="field"><span>{{ t('name') }}</span><input v-model="name" required /></label>
      <label class="field"><span>{{ t('email') }}</span><input :value="customer.user?.email" disabled /></label>
      <label class="field"><span>{{ t('phone') }}</span><input v-model="phone" /></label>
      <label class="field"><span>{{ t('organizationName') }}</span><input v-model="organization" /></label>
      <label class="field sm:col-span-2"><span>{{ t('profileNote') }}</span><textarea v-model="note" rows="4" /></label>
    </div>
    <button class="btn btn-primary mt-4" :disabled="loading">{{ t('save') }}</button>
  </form>
</template>
