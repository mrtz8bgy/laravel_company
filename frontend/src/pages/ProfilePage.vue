<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, ApiError, appHref } from '../api/client'
import { useUiStore } from '../stores/ui'

const ui = useUiStore()
const { t } = useI18n()
const profile = reactive({ name: '', phone: '', locale: 'fa', timezone: '', email: '', job_title: '', department: '', roles: '' })
const password = reactive({ current_password: '', password: '', password_confirmation: '' })
const sessions = ref<any[]>([])
const errors = ref<Record<string, string>>({})

function readErrors(error: unknown) {
  errors.value = {}
  if (!(error instanceof ApiError)) return
  for (const [key, messages] of Object.entries(error.errors || {})) errors.value[key] = messages[0] || error.message
}

async function load() {
  const me = (await api<any>('/profile')).data
  Object.assign(profile, {
    name: me.name,
    phone: me.phone || '',
    locale: me.locale,
    timezone: me.timezone || '',
    email: me.email || '',
    job_title: me.job_title || '',
    department: me.department?.name || '',
    roles: (me.roles || []).map((role: any) => role.name).join('، '),
  })
  sessions.value = (await api<any[]>('/auth/sessions')).data
}

async function save() {
  errors.value = {}
  try {
    await api('/profile', {
      method: 'PATCH',
      body: JSON.stringify({ name: profile.name, phone: profile.phone, locale: profile.locale, timezone: profile.timezone }),
    })
    ui.toast(t('save'))
    await load()
  } catch (error) {
    readErrors(error)
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

async function changePassword() {
  errors.value = {}
  try {
    await api('/profile', { method: 'PATCH', body: JSON.stringify(password) })
    password.current_password = ''
    password.password = ''
    password.password_confirmation = ''
    ui.toast(t('passwordChanged'))
  } catch (error) {
    readErrors(error)
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

async function revoke(uuid: string) {
  await api(`/auth/sessions/${uuid}`, { method: 'DELETE' })
  await load()
}

async function revokeAll() {
  await api('/auth/logout-all', { method: 'POST' })
  window.location.assign(appHref('/login'))
}

onMounted(load)
</script>

<template>
  <div class="grid gap-4 lg:grid-cols-2">
    <form class="panel p-5" @submit.prevent="save">
      <h1 class="mb-4 text-2xl font-semibold">{{ t('profile') }}</h1>
      <label class="field mb-3"><span>{{ t('name') }}</span><input v-model="profile.name" required /></label>
      <p v-if="errors.name" class="mb-3 text-sm text-danger">{{ errors.name }}</p>
      <label class="field mb-3"><span>{{ t('email') }}</span><input :value="profile.email" disabled /></label>
      <label class="field mb-3"><span>{{ t('jobTitle') }}</span><input :value="profile.job_title || '—'" disabled /></label>
      <label class="field mb-3"><span>{{ t('department') }}</span><input :value="profile.department || '—'" disabled /></label>
      <label class="field mb-3"><span>{{ t('role') }}</span><input :value="profile.roles || '—'" disabled /></label>
      <label class="field mb-3"><span>{{ t('phone') }}</span><input v-model="profile.phone" /></label>
      <label class="field mb-3">
        <span>{{ t('locale') }}</span>
        <select v-model="profile.locale"><option value="fa">فارسی</option><option value="en">English</option></select>
      </label>
      <label class="field mb-4"><span>{{ t('timezone') }}</span><input v-model="profile.timezone" placeholder="Asia/Tehran" /></label>
      <button class="btn btn-primary">{{ t('save') }}</button>
    </form>
    <form class="panel p-5" @submit.prevent="changePassword">
      <h2 class="mb-1 text-xl font-semibold">{{ t('newPassword') }}</h2>
      <p class="mb-4 text-sm text-muted">{{ t('passwordRules') }}</p>
      <label class="field mb-3"><span>{{ t('currentPassword') }}</span><input v-model="password.current_password" type="password" required autocomplete="current-password" /></label>
      <p v-if="errors.current_password" class="mb-3 text-sm text-danger">{{ errors.current_password }}</p>
      <label class="field mb-3"><span>{{ t('newPassword') }}</span><input v-model="password.password" type="password" required autocomplete="new-password" /></label>
      <p v-if="errors.password" class="mb-3 text-sm text-danger">{{ errors.password }}</p>
      <label class="field mb-4"><span>{{ t('passwordConfirm') }}</span><input v-model="password.password_confirmation" type="password" required autocomplete="new-password" /></label>
      <button class="btn btn-primary">{{ t('save') }}</button>
    </form>
    <section class="panel p-5 lg:col-span-2">
      <div class="mb-3 flex items-center justify-between">
        <h2 class="text-xl font-semibold">{{ t('sessions') }}</h2>
        <button class="btn btn-danger" @click="revokeAll">{{ t('logout') }}</button>
      </div>
      <article v-for="session in sessions" :key="session.uuid" class="table-row md:grid-cols-[1fr_auto_auto]">
        <div>
          <p class="font-medium">{{ session.device }} <span v-if="session.is_current" class="badge">current</span></p>
          <p class="text-xs text-muted">{{ session.ip }} · {{ session.logged_in_at }}</p>
        </div>
        <button v-if="!session.logged_out_at" class="btn btn-ghost" @click="revoke(session.uuid)">{{ t('delete') }}</button>
      </article>
    </section>
  </div>
</template>
