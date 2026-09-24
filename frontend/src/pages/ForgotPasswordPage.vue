<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, ApiError } from '../api/client'

const { t } = useI18n()
const email = ref('')
const message = ref('')
const error = ref('')

async function submit() {
  error.value = ''
  try {
    const response = await api('/auth/forgot-password', { method: 'POST', body: JSON.stringify({ email: email.value }) })
    message.value = response.message || ''
  } catch (err) {
    error.value = err instanceof ApiError ? err.message : 'Error'
  }
}
</script>

<template>
  <div class="flex min-h-screen items-center justify-center px-4">
    <form class="panel w-full max-w-md p-7" @submit.prevent="submit">
      <h1 class="text-2xl font-semibold">{{ t('forgot') }}</h1>
      <label class="field mt-5"><span>{{ t('email') }}</span><input v-model="email" type="email" required /></label>
      <p v-if="message" class="mt-3 text-sm text-emerald">{{ message }}</p>
      <p v-if="error" class="mt-3 text-sm text-danger">{{ error }}</p>
      <button class="btn btn-primary mt-4 w-full">{{ t('sendReset') }}</button>
      <router-link class="mt-4 inline-block text-sm text-emerald" to="/login">{{ t('back') }}</router-link>
    </form>
  </div>
</template>
