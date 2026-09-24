<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { api, ApiError } from '../api/client'
import { useAuthStore } from '../stores/auth'
import { useUiStore } from '../stores/ui'

const auth = useAuthStore()
const ui = useUiStore()
const router = useRouter()
const { t } = useI18n()
const step = ref(auth.token ? 1 : 0)
const company = reactive({
  company_name: '',
  admin_name: '',
  email: '',
  password: '',
  password_confirmation: '',
  timezone: 'Asia/Tehran',
  locale: 'fa',
})
const departmentName = ref('مدیریت')
const teamName = ref('تیم اصلی')
const departments = ref<any[]>([])

async function createCompany() {
  try {
    const response = await api<any>('/onboarding/company', { method: 'POST', body: JSON.stringify(company) })
    auth.apply(response.data)
    step.value = 1
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

async function addDepartment() {
  const response = await api<any[]>('/onboarding/departments', {
    method: 'POST',
    body: JSON.stringify({ departments: [{ name: departmentName.value }] }),
  })
  departments.value = response.data
  step.value = 2
}

async function addTeam() {
  if (!departments.value.length) departments.value = (await api<any[]>('/departments')).data
  await api('/onboarding/teams', {
    method: 'POST',
    body: JSON.stringify({ teams: [{ name: teamName.value, department_uuid: departments.value[0].uuid }] }),
  })
  step.value = 3
}

async function finish() {
  await api('/onboarding/complete', { method: 'POST' })
  await auth.fetchMe()
  router.push('/')
}
</script>

<template>
  <div class="mx-auto flex min-h-screen max-w-xl items-center px-4 py-10">
    <div class="panel w-full p-7">
      <p class="text-sm text-copper">{{ t('onboarding') }} · {{ step + 1 }}/4</p>
      <h1 class="mt-1 text-2xl font-semibold">{{ t('createCompany') }}</h1>
      <form v-if="step === 0" class="mt-6 space-y-3" @submit.prevent="createCompany">
        <label class="field"><span>{{ t('companyName') }}</span><input v-model="company.company_name" required /></label>
        <label class="field"><span>{{ t('adminName') }}</span><input v-model="company.admin_name" required /></label>
        <label class="field"><span>{{ t('email') }}</span><input v-model="company.email" type="email" required /></label>
        <label class="field"><span>{{ t('password') }}</span><input v-model="company.password" type="password" required /></label>
        <label class="field"><span>{{ t('passwordConfirm') }}</span><input v-model="company.password_confirmation" type="password" required /></label>
        <button class="btn btn-primary w-full">{{ t('next') }}</button>
      </form>
      <form v-else-if="step === 1" class="mt-6 space-y-3" @submit.prevent="addDepartment">
        <label class="field"><span>{{ t('departments') }}</span><input v-model="departmentName" required /></label>
        <button class="btn btn-primary w-full">{{ t('next') }}</button>
      </form>
      <form v-else-if="step === 2" class="mt-6 space-y-3" @submit.prevent="addTeam">
        <label class="field"><span>{{ t('teams') }}</span><input v-model="teamName" required /></label>
        <button class="btn btn-primary w-full">{{ t('next') }}</button>
      </form>
      <div v-else class="mt-6">
        <p class="text-muted">{{ t('principle3') }}</p>
        <button class="btn btn-primary mt-5 w-full" @click="finish">{{ t('finish') }}</button>
      </div>
      <router-link class="mt-4 inline-block text-sm text-emerald" to="/login">{{ t('back') }}</router-link>
    </div>
  </div>
</template>
