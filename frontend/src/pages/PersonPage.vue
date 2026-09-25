<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { api, ApiError } from '../api/client'
import { useAuthStore } from '../stores/auth'
import { useUiStore } from '../stores/ui'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()
const ui = useUiStore()
const { t } = useI18n()

const person = ref<any>(null)
const roles = ref<any[]>([])
const departments = ref<any[]>([])
const missing = ref(false)
const form = reactive({
  name: '',
  phone: '',
  job_title: '',
  employee_code: '',
  department_uuid: '',
  role_slug: '',
  status: 'active',
})
const password = reactive({ password: '', password_confirmation: '' })
const errors = ref<Record<string, string>>({})

function apply(row: any) {
  person.value = row
  form.name = row.name || ''
  form.phone = row.phone || ''
  form.job_title = row.job_title || ''
  form.employee_code = row.employee_code || ''
  form.department_uuid = row.department?.uuid || ''
  form.role_slug = row.roles?.[0]?.slug || ''
  form.status = row.membership_status || row.status || 'active'
}

function fieldError(error: unknown) {
  errors.value = {}
  if (!(error instanceof ApiError)) {
    ui.toast('Error', 'bad')
    return
  }
  for (const [key, messages] of Object.entries(error.errors || {})) {
    errors.value[key] = messages[0] || error.message
  }
  ui.toast(error.message, 'bad')
}

async function load() {
  const uuid = String(route.params.uuid)
  try {
    apply((await api<any>(`/users/${uuid}`)).data)
  } catch {
    missing.value = true
    return
  }
  if (auth.can('roles.view')) roles.value = (await api<any[]>('/roles')).data
  if (auth.can('departments.view')) departments.value = (await api<any[]>('/departments')).data
}

async function save() {
  errors.value = {}
  const body: Record<string, unknown> = {
    name: form.name,
    phone: form.phone || null,
    job_title: form.job_title || null,
    employee_code: form.employee_code || null,
    department_uuid: form.department_uuid || null,
    status: form.status,
  }
  if (auth.can('roles.view') && form.role_slug) body.role_slugs = [form.role_slug]
  try {
    apply((await api<any>(`/users/${route.params.uuid}`, { method: 'PATCH', body: JSON.stringify(body) })).data)
    ui.toast(t('save'))
  } catch (error) {
    fieldError(error)
  }
}

async function setPassword() {
  errors.value = {}
  if (password.password !== password.password_confirmation) {
    errors.value.password_confirmation = t('passwordConfirm')
    return
  }
  try {
    await api(`/users/${route.params.uuid}`, {
      method: 'PATCH',
      body: JSON.stringify(password),
    })
    password.password = ''
    password.password_confirmation = ''
    ui.toast(t('passwordReset'))
  } catch (error) {
    fieldError(error)
  }
}

onMounted(load)
</script>

<template>
  <div class="mx-auto max-w-3xl">
    <button class="btn btn-ghost mb-4" type="button" @click="router.push('/people')">{{ t('back') }}</button>
    <p v-if="missing" class="panel p-6 text-muted">{{ t('empty') }}</p>
    <template v-else-if="person">
      <header class="panel mb-4 p-6">
        <p class="kicker">{{ t('personProfile') }}</p>
        <h1 class="mt-2 text-3xl font-semibold">{{ person.name }}</h1>
        <p class="mt-1 text-sm text-muted">{{ person.email }}</p>
        <div class="mt-3 flex flex-wrap gap-2 text-sm">
          <span v-if="person.is_owner" class="badge">{{ t('owner') }}</span>
          <span class="badge">{{ form.status === 'suspended' ? t('suspended') : t('active') }}</span>
          <span v-for="role in person.roles || []" :key="role.uuid" class="badge">{{ role.name }}</span>
        </div>
        <router-link
          v-if="auth.feature('attendance') && auth.can('attendance.view')"
          class="btn btn-primary mt-4"
          :to="`/people/${route.params.uuid}/work`"
        >
          {{ t('workReport') }}
        </router-link>
      </header>

      <form v-if="auth.can('users.update')" class="panel mb-4 p-6" @submit.prevent="save">
        <h2 class="mb-4 text-xl font-semibold">{{ t('edit') }}</h2>
        <label class="field mb-3"><span>{{ t('name') }}</span><input v-model="form.name" required /></label>
        <p v-if="errors.name" class="mb-3 text-sm text-danger">{{ errors.name }}</p>
        <label class="field mb-3"><span>{{ t('email') }}</span><input :value="person.email" disabled /></label>
        <p class="mb-3 text-xs text-muted">{{ t('emailLocked') }}</p>
        <label class="field mb-3"><span>{{ t('phone') }}</span><input v-model="form.phone" /></label>
        <label class="field mb-3"><span>{{ t('jobTitle') }}</span><input v-model="form.job_title" /></label>
        <label class="field mb-3"><span>{{ t('employeeCode') }}</span><input v-model="form.employee_code" /></label>
        <label class="field mb-3">
          <span>{{ t('department') }}</span>
          <select v-model="form.department_uuid">
            <option value="">{{ t('none') }}</option>
            <option v-for="department in departments" :key="department.uuid" :value="department.uuid">{{ department.name }}</option>
          </select>
        </label>
        <label v-if="roles.length" class="field mb-3">
          <span>{{ t('role') }}</span>
          <select v-model="form.role_slug">
            <option v-for="role in roles" :key="role.uuid" :value="role.slug">{{ role.name }}</option>
          </select>
        </label>
        <label class="field mb-4">
          <span>{{ t('status') }}</span>
          <select v-model="form.status">
            <option value="active">{{ t('active') }}</option>
            <option value="suspended">{{ t('suspended') }}</option>
          </select>
        </label>
        <button class="btn btn-primary">{{ t('save') }}</button>
      </form>

      <form v-if="auth.can('users.update')" class="panel p-6" @submit.prevent="setPassword">
        <h2 class="mb-1 text-xl font-semibold">{{ t('setPassword') }}</h2>
        <p class="mb-4 text-sm text-muted">{{ t('passwordRules') }}</p>
        <label class="field mb-3"><span>{{ t('newPassword') }}</span><input v-model="password.password" type="password" required autocomplete="new-password" /></label>
        <p v-if="errors.password" class="mb-3 text-sm text-danger">{{ errors.password }}</p>
        <label class="field mb-4"><span>{{ t('passwordConfirm') }}</span><input v-model="password.password_confirmation" type="password" required autocomplete="new-password" /></label>
        <p v-if="errors.password_confirmation" class="mb-3 text-sm text-danger">{{ errors.password_confirmation }}</p>
        <button class="btn btn-primary">{{ t('save') }}</button>
      </form>
    </template>
  </div>
</template>
