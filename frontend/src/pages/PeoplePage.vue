<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { api, ApiError } from '../api/client'
import { useAuthStore } from '../stores/auth'
import { useUiStore } from '../stores/ui'

const auth = useAuthStore()
const ui = useUiStore()
const { t } = useI18n()
const rows = ref<any[]>([])
const roles = ref<any[]>([])
const departments = ref<any[]>([])
const open = ref(false)
const form = reactive({
  name: '',
  email: '',
  password: '123456',
  job_title: '',
  employee_code: '',
  department_uuid: '',
  role_slugs: ['employee'] as string[],
})

async function load() {
  const response = await api<any[]>('/users?per_page=100')
  rows.value = response.data
  if (auth.can('roles.view')) roles.value = (await api<any[]>('/roles')).data
  if (auth.can('departments.view')) departments.value = (await api<any[]>('/departments')).data
}

async function save() {
  try {
    await api('/users', {
      method: 'POST',
      body: JSON.stringify({
        ...form,
        department_uuid: form.department_uuid || null,
        employee_code: form.employee_code || null,
      }),
    })
    open.value = false
    ui.toast(t('save'))
    await load()
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

async function remove(uuid: string) {
  if (!confirm(t('delete'))) return
  try {
    await api(`/users/${uuid}`, { method: 'DELETE' })
    await load()
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

onMounted(load)
</script>

<template>
  <div>
    <div class="mb-5 flex items-end justify-between">
      <div>
        <p class="text-sm text-copper">{{ t('people') }}</p>
        <h1 class="text-3xl font-semibold">{{ t('people') }}</h1>
      </div>
      <button v-if="auth.can('users.create')" class="btn btn-primary" @click="open = true">{{ t('create') }}</button>
    </div>
    <section class="sheet">
      <table>
        <thead>
          <tr>
            <th>{{ t('name') }}</th>
            <th>{{ t('jobTitle') }}</th>
            <th>{{ t('role') }}</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in rows" :key="row.uuid">
            <td>
              <p class="font-medium">{{ row.name }} <span v-if="row.is_owner" class="badge">{{ t('owner') }}</span></p>
              <p class="text-xs text-muted">{{ row.email }}</p>
            </td>
            <td>{{ row.job_title || '—' }}</td>
            <td class="text-muted">{{ row.roles?.map((role: any) => role.name).join('، ') }}</td>
            <td class="flex justify-end gap-2">
              <RouterLink v-if="auth.feature('attendance') && auth.can('attendance.view')" class="btn btn-ghost" :to="`/people/${row.uuid}/work`">{{ t('workReport') }}</RouterLink>
              <RouterLink class="btn btn-ghost" :to="`/people/${row.uuid}`">{{ auth.can('users.update') ? t('edit') : t('view') }}</RouterLink>
              <button v-if="auth.can('users.delete') && !row.is_owner" class="btn btn-danger" @click="remove(row.uuid)">{{ t('delete') }}</button>
            </td>
          </tr>
        </tbody>
      </table>
    </section>
    <div v-if="open" class="fixed inset-0 z-50 flex items-center justify-center bg-ink/40 p-4" @click.self="open = false">
      <form class="panel max-h-[90vh] w-full max-w-lg overflow-auto p-6" @submit.prevent="save">
        <h2 class="mb-4 text-xl font-semibold">{{ t('create') }}</h2>
        <label class="field mb-3"><span>{{ t('name') }}</span><input v-model="form.name" required /></label>
        <label class="field mb-3"><span>{{ t('email') }}</span><input v-model="form.email" type="email" required /></label>
        <label class="field mb-3"><span>{{ t('password') }}</span><input v-model="form.password" required /></label>
        <label class="field mb-3"><span>{{ t('jobTitle') }}</span><input v-model="form.job_title" /></label>
        <label class="field mb-3"><span>{{ t('employeeCode') }}</span><input v-model="form.employee_code" /></label>
        <label class="field mb-3">
          <span>{{ t('department') }}</span>
          <select v-model="form.department_uuid">
            <option value="">—</option>
            <option v-for="department in departments" :key="department.uuid" :value="department.uuid">{{ department.name }}</option>
          </select>
        </label>
        <label class="field mb-4">
          <span>{{ t('role') }}</span>
          <select v-model="form.role_slugs[0]">
            <option v-for="role in roles" :key="role.uuid" :value="role.slug">{{ role.name }}</option>
          </select>
        </label>
        <div class="flex justify-end gap-2">
          <button type="button" class="btn btn-ghost" @click="open = false">{{ t('cancel') }}</button>
          <button class="btn btn-primary">{{ t('save') }}</button>
        </div>
      </form>
    </div>
  </div>
</template>
