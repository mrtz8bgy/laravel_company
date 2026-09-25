<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useAuthStore } from '../stores/auth'
import { useUiStore } from '../stores/ui'
import { applyLocale } from '../i18n'
import { ApiError } from '../api/client'

const auth = useAuthStore()
const ui = useUiStore()
const router = useRouter()
const { t, locale } = useI18n()
const email = ref('')
const password = ref('')
const companyUuid = ref('')
const companies = ref<{ uuid: string; name: string }[]>([])
const loading = ref(false)
const error = ref('')

function fillDemo() {
  email.value = 'ceo@ideban.test'
  password.value = '123456'
}

async function submit() {
  loading.value = true
  error.value = ''
  try {
    const result = await auth.login(email.value, password.value, companyUuid.value || undefined)
    if (result.requires_company) {
      companies.value = result.companies || []
      return
    }
    router.push(auth.onboarded ? '/' : '/onboarding')
  } catch (err) {
    error.value = err instanceof ApiError ? err.message : 'Error'
    ui.toast(error.value, 'bad')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="grid min-h-screen lg:grid-cols-[1.1fr_.9fr]">
    <section class="relative hidden overflow-hidden bg-ink text-white lg:flex lg:flex-col lg:justify-between lg:p-14">
      <div class="absolute inset-0 opacity-30" style="background-image: linear-gradient(120deg, transparent 40%, rgba(198,163,106,.28) 41%, transparent 42%); background-size: 28px 28px;" />
      <div class="relative flex items-center gap-3">
        <span class="mark"><span /></span>
        <span class="text-xs tracking-[0.18em] text-brass">{{ t('brandEn') }}</span>
      </div>
      <div class="relative max-w-lg">
        <p class="kicker !text-brass">VIRTUAL COMPANY OS</p>
        <h1 class="mt-4 text-5xl font-semibold leading-tight">{{ t('brand') }}</h1>
        <hr class="rule max-w-40" />
        <p class="mt-6 text-lg text-white/70">{{ t('tagline') }}</p>
        <ul class="mt-8 space-y-3 text-sm text-white/60">
          <li>{{ t('principle1') }}</li>
          <li>{{ t('principle2') }}</li>
          <li>{{ t('principle3') }}</li>
        </ul>
      </div>
      <p class="relative text-xs text-white/35">Asia/Tehran</p>
    </section>
    <section class="flex items-center justify-center bg-paper px-5 py-10">
      <form class="panel w-full max-w-md p-8" @submit.prevent="submit">
        <div class="mb-6 flex items-start justify-between gap-3">
          <div>
            <p class="kicker">{{ t('brandEn') }}</p>
            <h2 class="mt-2 text-3xl font-semibold">{{ t('login') }}</h2>
          </div>
          <button type="button" class="btn btn-ghost" @click="applyLocale(locale === 'fa' ? 'en' : 'fa')">{{ t('language') }}</button>
        </div>
        <div class="mb-5 rounded-2xl border border-line bg-copper-soft/70 p-4 text-sm">
          <p class="font-semibold">{{ t('demoTitle') }}</p>
          <p class="mt-1 text-muted">{{ t('demoHint') }} · ceo@ideban.test</p>
          <button type="button" class="btn btn-ghost mt-3" @click="fillDemo">{{ t('useDemo') }}</button>
        </div>
        <label class="field mb-3"><span>{{ t('email') }}</span><input v-model="email" type="email" required autocomplete="username" /></label>
        <label class="field mb-3"><span>{{ t('password') }}</span><input v-model="password" type="password" required autocomplete="current-password" /></label>
        <label v-if="companies.length" class="field mb-3">
          <span>{{ t('companyName') }}</span>
          <select v-model="companyUuid" required>
            <option value="" disabled>{{ t('none') }}</option>
            <option v-for="company in companies" :key="company.uuid" :value="company.uuid">{{ company.name }}</option>
          </select>
        </label>
        <p v-if="error" class="mb-3 text-sm text-danger">{{ error }}</p>
        <button class="btn btn-primary mt-2 w-full" :disabled="loading">{{ loading ? t('signingIn') : t('login') }}</button>
        <div class="mt-5 flex justify-between text-sm">
          <router-link class="text-muted" to="/forgot-password">{{ t('forgot') }}</router-link>
          <router-link to="/onboarding">{{ t('createCompany') }}</router-link>
        </div>
      </form>
    </section>
  </div>
</template>
