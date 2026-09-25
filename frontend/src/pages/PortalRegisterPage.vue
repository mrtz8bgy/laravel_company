<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { api, ApiError } from '../api/client'
import { useAuthStore } from '../stores/auth'
import { useUiStore } from '../stores/ui'

const auth = useAuthStore()
const ui = useUiStore()
const router = useRouter()
const { t } = useI18n()
const companySlug = ref('ideban-almas')
const companyName = ref('')
const name = ref('')
const email = ref('')
const password = ref('')
const passwordConfirmation = ref('')
const phone = ref('')
const organizationName = ref('')
const loading = ref(false)
const error = ref('')

async function loadCompany() {
  companyName.value = ''
  if (!companySlug.value) return
  try {
    const response = await api<{ name: string }>('/portal/companies/' + encodeURIComponent(companySlug.value))
    companyName.value = response.data.name
  } catch {
    companyName.value = ''
  }
}

onMounted(loadCompany)

async function submit() {
  loading.value = true
  error.value = ''
  try {
    const response = await api<any>('/portal/register', {
      method: 'POST',
      body: JSON.stringify({
        company_slug: companySlug.value,
        name: name.value,
        email: email.value,
        password: password.value,
        password_confirmation: passwordConfirmation.value,
        phone: phone.value || null,
        organization_name: organizationName.value || null,
      }),
    })
    auth.apply(response.data)
    ui.toast(response.message || t('awaitingApproval'))
    router.push('/portal')
  } catch (err) {
    error.value = err instanceof ApiError ? err.message : 'Error'
    ui.toast(error.value, 'bad')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <form class="panel mx-auto max-w-xl p-6 sm:p-8" @submit.prevent="submit">
    <p class="kicker">{{ t('customerPortal') }}</p>
    <h1 class="mt-2 text-3xl font-semibold">{{ t('customerRegister') }}</h1>
    <p class="mt-2 text-sm text-muted">{{ t('portalHint') }}</p>
    <p v-if="companyName" class="mt-4 rounded-2xl bg-mint px-4 py-3 text-sm text-emerald">{{ companyName }}</p>
    <div class="mt-6 grid gap-3 sm:grid-cols-2">
      <label class="field sm:col-span-2"><span>{{ t('companySlug') }}</span><input v-model="companySlug" required @change="loadCompany" /></label>
      <label class="field"><span>{{ t('name') }}</span><input v-model="name" required /></label>
      <label class="field"><span>{{ t('organizationName') }}</span><input v-model="organizationName" /></label>
      <label class="field"><span>{{ t('email') }}</span><input v-model="email" type="email" required autocomplete="username" /></label>
      <label class="field"><span>{{ t('phone') }}</span><input v-model="phone" /></label>
      <label class="field"><span>{{ t('password') }}</span><input v-model="password" type="password" required autocomplete="new-password" /></label>
      <label class="field"><span>{{ t('passwordConfirm') }}</span><input v-model="passwordConfirmation" type="password" required /></label>
    </div>
    <p class="mt-3 text-xs text-muted">{{ t('passwordRule') }}</p>
    <p v-if="error" class="mt-3 text-sm text-danger">{{ error }}</p>
    <button class="btn btn-primary mt-5" :disabled="loading">{{ loading ? t('registering') : t('registerCustomer') }}</button>
  </form>
</template>
