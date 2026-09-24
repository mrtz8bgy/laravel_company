<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { api, ApiError } from '../api/client'
import { useAuthStore } from '../stores/auth'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()
const { t } = useI18n()
const form = reactive({
  token: String(route.query.token || ''),
  name: '',
  password: '',
  password_confirmation: '',
})
const error = ref('')

async function submit() {
  try {
    const response = await api<any>('/auth/accept-invite', { method: 'POST', body: JSON.stringify(form) })
    auth.apply(response.data)
    router.push('/')
  } catch (err) {
    error.value = err instanceof ApiError ? err.message : 'Error'
  }
}
</script>

<template>
  <div class="flex min-h-screen items-center justify-center px-4">
    <form class="panel w-full max-w-md p-7" @submit.prevent="submit">
      <h1 class="text-2xl font-semibold">{{ t('acceptInvite') }}</h1>
      <label class="field mt-5"><span>{{ t('name') }}</span><input v-model="form.name" required /></label>
      <label class="field mt-3"><span>{{ t('password') }}</span><input v-model="form.password" type="password" required /></label>
      <label class="field mt-3"><span>{{ t('passwordConfirm') }}</span><input v-model="form.password_confirmation" type="password" required /></label>
      <p v-if="error" class="mt-3 text-sm text-danger">{{ error }}</p>
      <button class="btn btn-primary mt-4 w-full">{{ t('acceptInvite') }}</button>
    </form>
  </div>
</template>
