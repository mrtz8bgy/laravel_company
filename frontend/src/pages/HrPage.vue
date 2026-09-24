<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, ApiError } from '../api/client'
import { useAuthStore } from '../stores/auth'
import { useUiStore } from '../stores/ui'

const auth = useAuthStore()
const ui = useUiStore()
const { t } = useI18n()
const me = ref<any>(null)
const leaves = ref<any[]>([])
const missions = ref<any[]>([])
const people = ref<any[]>([])
const selected = ref('')
const dossier = ref<any>(null)
const leave = reactive({ type: 'annual', starts_on: '', ends_on: '', reason: '' })
const mission = reactive({ destination: '', starts_on: '', ends_on: '', purpose: '' })
const profile = reactive({
  employment_type: 'full_time',
  hire_date: '',
  emergency_name: '',
  emergency_phone: '',
  notes: '',
  national_id: '',
  salary_amount: '',
  salary_currency: 'IRR',
})

const canReviewLeave = computed(() => auth.can('leave.review'))
const canReviewMission = computed(() => auth.can('mission.review'))
const canSeeSalary = computed(() => auth.can('hr.salary.view'))

async function load() {
  if (auth.can('leave.request')) me.value = (await api<any>('/hr/me')).data
  if (auth.can('leave.request')) leaves.value = (await api<any[]>('/hr/leave')).data
  if (auth.can('mission.request')) missions.value = (await api<any[]>('/hr/missions')).data
  if (auth.can('hr.profile.view') && auth.can('users.view')) people.value = (await api<any[]>('/users')).data
}

async function submitLeave() {
  try {
    await api('/hr/leave', { method: 'POST', body: JSON.stringify(leave) })
    leave.reason = ''
    ui.toast(t('save'))
    await load()
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

async function submitMission() {
  try {
    await api('/hr/missions', { method: 'POST', body: JSON.stringify(mission) })
    mission.purpose = ''
    ui.toast(t('save'))
    await load()
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

async function review(kind: 'leave' | 'missions', uuid: string, decision: 'approved' | 'rejected') {
  try {
    await api(`/hr/${kind}/${uuid}/review`, { method: 'POST', body: JSON.stringify({ decision }) })
    ui.toast(t('save'))
    await load()
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

async function openPerson() {
  if (!selected.value) return
  dossier.value = (await api<any>(`/hr/people/${selected.value}`)).data
  profile.employment_type = dossier.value.employment_type || 'full_time'
  profile.hire_date = dossier.value.hire_date || ''
  profile.emergency_name = dossier.value.emergency_name || ''
  profile.emergency_phone = dossier.value.emergency_phone || ''
  profile.notes = dossier.value.notes || ''
  profile.national_id = dossier.value.national_id || ''
  profile.salary_amount = dossier.value.salary_amount || ''
  profile.salary_currency = dossier.value.salary_currency || 'IRR'
}

async function saveProfile() {
  const payload: Record<string, unknown> = {
    employment_type: profile.employment_type,
    hire_date: profile.hire_date || null,
    emergency_name: profile.emergency_name || null,
    emergency_phone: profile.emergency_phone || null,
    notes: profile.notes || null,
  }
  if (canSeeSalary.value) {
    payload.national_id = profile.national_id || null
    payload.salary_amount = profile.salary_amount === '' ? null : Number(profile.salary_amount)
    payload.salary_currency = profile.salary_currency || null
  }
  try {
    dossier.value = (await api<any>(`/hr/people/${selected.value}`, { method: 'PATCH', body: JSON.stringify(payload) })).data
    ui.toast(t('save'))
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

onMounted(load)
</script>

<template>
  <div>
    <p class="text-sm text-copper">{{ t('hr') }}</p>
    <h1 class="mt-1 text-3xl font-semibold">{{ t('hr') }}</h1>
    <p class="mt-2 text-sm text-muted">{{ t('sensitiveHidden') }}</p>

    <section v-if="me" class="panel mt-5 p-5">
      <h2 class="font-semibold">{{ me.user?.name }}</h2>
      <p class="mt-1 text-sm text-muted">{{ me.job_title || t('none') }} · {{ me.employee_code || '—' }}</p>
      <p class="mt-1 text-sm">{{ me.employment_type ? t(`employment_${me.employment_type}`) : '' }} {{ me.hire_date || '' }}</p>
    </section>

    <div class="mt-4 grid gap-4 lg:grid-cols-2">
      <form class="panel p-5" @submit.prevent="submitLeave">
        <h2 class="font-semibold">{{ t('leave') }}</h2>
        <label class="field mt-3">
          <span>{{ t('status') }}</span>
          <select v-model="leave.type">
            <option value="annual">{{ t('leave_annual') }}</option>
            <option value="sick">{{ t('leave_sick') }}</option>
            <option value="unpaid">{{ t('leave_unpaid') }}</option>
            <option value="hourly">{{ t('leave_hourly') }}</option>
          </select>
        </label>
        <div class="mt-3 grid grid-cols-2 gap-3">
          <label class="field"><span>{{ t('startsOn') }}</span><input v-model="leave.starts_on" type="date" required /></label>
          <label class="field"><span>{{ t('endsOn') }}</span><input v-model="leave.ends_on" type="date" required /></label>
        </div>
        <label class="field mt-3"><span>{{ t('reason') }}</span><textarea v-model="leave.reason" rows="3" required minlength="3" /></label>
        <button class="btn btn-primary mt-3">{{ t('submit') }}</button>
        <div v-for="item in leaves" :key="item.uuid" class="mt-3 rounded-xl border border-line p-3 text-sm">
          <div class="flex items-center justify-between gap-2">
            <span>{{ item.user?.name }} · {{ t(`leave_${item.type}`) }}</span>
            <span class="badge">{{ t(`request_${item.status}`) }}</span>
          </div>
          <p class="mt-1 text-muted">{{ item.starts_on }} → {{ item.ends_on }}</p>
          <div v-if="canReviewLeave && item.status === 'pending' && item.user?.uuid !== auth.user?.uuid" class="mt-2 flex gap-2">
            <button type="button" class="btn btn-primary" @click="review('leave', item.uuid, 'approved')">{{ t('approve') }}</button>
            <button type="button" class="btn btn-ghost" @click="review('leave', item.uuid, 'rejected')">{{ t('reject') }}</button>
          </div>
        </div>
      </form>

      <form class="panel p-5" @submit.prevent="submitMission">
        <h2 class="font-semibold">{{ t('mission') }}</h2>
        <label class="field mt-3"><span>{{ t('destination') }}</span><input v-model="mission.destination" required maxlength="160" /></label>
        <div class="mt-3 grid grid-cols-2 gap-3">
          <label class="field"><span>{{ t('startsOn') }}</span><input v-model="mission.starts_on" type="date" required /></label>
          <label class="field"><span>{{ t('endsOn') }}</span><input v-model="mission.ends_on" type="date" required /></label>
        </div>
        <label class="field mt-3"><span>{{ t('purpose') }}</span><textarea v-model="mission.purpose" rows="3" required minlength="3" /></label>
        <button class="btn btn-primary mt-3">{{ t('submit') }}</button>
        <div v-for="item in missions" :key="item.uuid" class="mt-3 rounded-xl border border-line p-3 text-sm">
          <div class="flex items-center justify-between gap-2">
            <span>{{ item.user?.name }} · {{ item.destination }}</span>
            <span class="badge">{{ t(`request_${item.status}`) }}</span>
          </div>
          <div v-if="canReviewMission && item.status === 'pending' && item.user?.uuid !== auth.user?.uuid" class="mt-2 flex gap-2">
            <button type="button" class="btn btn-primary" @click="review('missions', item.uuid, 'approved')">{{ t('approve') }}</button>
            <button type="button" class="btn btn-ghost" @click="review('missions', item.uuid, 'rejected')">{{ t('reject') }}</button>
          </div>
        </div>
      </form>
    </div>

    <section v-if="auth.can('hr.profile.update')" class="panel mt-4 p-5">
      <h2 class="font-semibold">{{ t('people') }}</h2>
      <form class="mt-3 flex flex-wrap gap-2" @submit.prevent="openPerson">
        <select v-model="selected" class="min-w-56 rounded-xl border border-line bg-transparent px-3 py-2">
          <option value="">{{ t('assignee') }}</option>
          <option v-for="person in people" :key="person.uuid" :value="person.uuid">{{ person.name }}</option>
        </select>
        <button class="btn btn-ghost" :disabled="!selected">{{ t('edit') }}</button>
      </form>
      <form v-if="dossier" class="mt-4 grid gap-3 md:grid-cols-2" @submit.prevent="saveProfile">
        <label class="field">
          <span>{{ t('employmentType') }}</span>
          <select v-model="profile.employment_type">
            <option value="full_time">{{ t('employment_full_time') }}</option>
            <option value="part_time">{{ t('employment_part_time') }}</option>
            <option value="contract">{{ t('employment_contract') }}</option>
            <option value="intern">{{ t('employment_intern') }}</option>
          </select>
        </label>
        <label class="field"><span>{{ t('hireDate') }}</span><input v-model="profile.hire_date" type="date" /></label>
        <label class="field"><span>{{ t('emergency') }}</span><input v-model="profile.emergency_name" /></label>
        <label class="field"><span>{{ t('phone') }}</span><input v-model="profile.emergency_phone" /></label>
        <label v-if="canSeeSalary" class="field"><span>{{ t('nationalId') }}</span><input v-model="profile.national_id" /></label>
        <label v-if="canSeeSalary" class="field"><span>{{ t('salary') }}</span><input v-model="profile.salary_amount" inputmode="numeric" /></label>
        <label class="field md:col-span-2"><span>{{ t('note') }}</span><textarea v-model="profile.notes" rows="2" /></label>
        <button class="btn btn-primary w-fit">{{ t('save') }}</button>
      </form>
    </section>
  </div>
</template>
