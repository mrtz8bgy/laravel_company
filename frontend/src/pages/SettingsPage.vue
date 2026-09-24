<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, ApiError } from '../api/client'
import { useAuthStore } from '../stores/auth'
import { useUiStore } from '../stores/ui'

const auth = useAuthStore()
const ui = useUiStore()
const { t } = useI18n()
const company = reactive({ name: '', legal_name: '', timezone: 'Asia/Tehran', locale: 'fa' })
const days = ref<any[]>([])
const features = ref<any[]>([])
const week = ['یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه', 'شنبه']

async function load() {
  const current = (await api<any>('/company')).data
  Object.assign(company, {
    name: current.name,
    legal_name: current.legal_name,
    timezone: current.timezone,
    locale: current.locale,
  })
  days.value = (await api<any[]>('/work-schedules')).data
  if (auth.can('features.view')) features.value = (await api<any[]>('/features')).data
}

async function saveCompany() {
  try {
    await api('/company', { method: 'PATCH', body: JSON.stringify(company) })
    ui.toast(t('save'))
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

async function toggleFeature(feature: { key: string; enabled: boolean }, enabled: boolean) {
  try {
    await api(`/features/${feature.key}`, { method: 'PATCH', body: JSON.stringify({ enabled }) })
    feature.enabled = enabled
    auth.features = { ...auth.features, [feature.key]: enabled }
    ui.toast(t('save'))
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
    await load()
  }
}

async function saveSchedule() {
  try {
    await api('/work-schedules', { method: 'PUT', body: JSON.stringify({ days: days.value }) })
    ui.toast(t('save'))
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

onMounted(load)
</script>

<template>
  <div class="grid gap-4">
    <div>
      <p class="text-sm text-copper">{{ t('settings') }}</p>
      <h1 class="text-3xl font-semibold">{{ t('settings') }}</h1>
    </div>
    <form class="panel p-5" @submit.prevent="saveCompany">
      <div class="grid gap-3 md:grid-cols-2">
        <label class="field"><span>{{ t('companyName') }}</span><input v-model="company.name" :disabled="!auth.can('company.update')" /></label>
        <label class="field"><span>{{ t('legalName') }}</span><input v-model="company.legal_name" :disabled="!auth.can('company.update')" /></label>
        <label class="field"><span>{{ t('timezone') }}</span><input v-model="company.timezone" :disabled="!auth.can('company.update')" /></label>
        <label class="field">
          <span>{{ t('locale') }}</span>
          <select v-model="company.locale" :disabled="!auth.can('company.update')">
            <option value="fa">فارسی</option>
            <option value="en">English</option>
          </select>
        </label>
      </div>
      <button v-if="auth.can('company.update')" class="btn btn-primary mt-4">{{ t('save') }}</button>
    </form>
    <form class="panel p-5" @submit.prevent="saveSchedule">
      <h2 class="mb-4 font-semibold">{{ t('workingHours') }}</h2>
      <div class="space-y-3">
        <div v-for="day in days" :key="day.weekday" class="grid items-center gap-2 rounded-2xl border border-line p-3 md:grid-cols-[8rem_auto_1fr_1fr_1fr_1fr]">
          <strong>{{ week[day.weekday] }}</strong>
          <label class="flex items-center gap-2 text-sm"><input v-model="day.is_working_day" type="checkbox" /> {{ t('workingDay') }}</label>
          <label class="field"><span>{{ t('start') }}</span><input v-model="day.start_time" type="time" /></label>
          <label class="field"><span>{{ t('end') }}</span><input v-model="day.end_time" type="time" /></label>
          <label class="field"><span>{{ t('break') }}</span><input v-model.number="day.break_minutes" type="number" min="0" /></label>
          <label class="field"><span>{{ t('grace') }}</span><input v-model.number="day.grace_minutes" type="number" min="0" /></label>
        </div>
      </div>
      <button v-if="auth.can('company.settings.manage')" class="btn btn-primary mt-4">{{ t('save') }}</button>
    </form>
    <section v-if="features.length" class="panel p-5">
      <h2 class="mb-3 font-semibold">{{ t('features') }}</h2>
      <div class="grid gap-2">
        <label v-for="feature in features" :key="feature.key" class="flex items-center justify-between gap-3 rounded-2xl border border-line px-3 py-2">
          <span>{{ t(`feature_${feature.key}`) }}</span>
          <input
            type="checkbox"
            :checked="feature.enabled"
            :disabled="feature.key === 'foundation' || !auth.can('features.manage')"
            @change="toggleFeature(feature, ($event.target as HTMLInputElement).checked)"
          />
        </label>
      </div>
    </section>
  </div>
</template>
