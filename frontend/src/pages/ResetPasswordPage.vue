<script setup lang="ts">
import { reactive } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { api, ApiError } from '../api/client'
import { useUiStore } from '../stores/ui'

const route = useRoute()
const router = useRouter()
const ui = useUiStore()
const { t } = useI18n()
const form = reactive({
  email: String(route.query.email || ''),
  token: String(route.query.token || ''),
  password: '',
  password_confirmation: '',
})

async function submit() {
  try {
    await api('/auth/reset-password', { method: 'POST', body: JSON.stringify(form) })
    ui.toast(t('save'))
    router.push('/login')
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}
</script>

<template>
  <div class="flex min-h-screen items-center justify-center px-4">
    <form class="panel w-full max-w-md p-7" @submit.prevent="submit">
      <h1 class="text-2xl font-semibold">{{ t('newPassword') }}</h1>
      <label class="field mt-5"><span>{{ t('email') }}</span><input v-model="form.email" type="email" required /></label>
      <label class="field mt-3"><span>{{ t('newPassword') }}</span><input v-model="form.password" type="password" required /></label>
      <label class="field mt-3"><span>{{ t('passwordConfirm') }}</span><input v-model="form.password_confirmation" type="password" required /></label>
      <button class="btn btn-primary mt-4 w-full">{{ t('save') }}</button>
    </form>
  </div>
</template>
