<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api } from '../api/client'
import JalaliDateInput from '../components/JalaliDateInput.vue'

const { t } = useI18n()
const board = ref<any>(null)
const date = ref('')

async function load() {
  const query = date.value ? `?date=${date.value}` : ''
  board.value = (await api<any>(`/attendance/board${query}`)).data
  if (!date.value) date.value = board.value.date
}

onMounted(load)
</script>

<template>
  <div>
    <div class="mb-5 flex flex-wrap items-end justify-between gap-3">
      <div>
        <p class="text-sm text-copper">{{ t('virtualOffice') }}</p>
        <h1 class="text-3xl font-semibold">{{ t('attendanceBoard') }}</h1>
      </div>
      <label class="field w-52">
        <span>{{ t('workingToday') }}</span>
        <JalaliDateInput v-model="date" @update:model-value="load" />
      </label>
    </div>
    <div v-if="board" class="mb-4 grid gap-3 sm:grid-cols-4">
      <article class="panel p-4"><p class="text-sm text-muted">{{ t('people') }}</p><p class="text-2xl font-semibold">{{ board.summary.people }}</p></article>
      <article class="panel p-4"><p class="text-sm text-muted">{{ t('presentToday') }}</p><p class="text-2xl font-semibold">{{ board.summary.present }}</p></article>
      <article class="panel p-4"><p class="text-sm text-muted">{{ t('status_remote') }}</p><p class="text-2xl font-semibold">{{ board.summary.remote }}</p></article>
      <article class="panel p-4"><p class="text-sm text-muted">{{ t('late') }}</p><p class="text-2xl font-semibold">{{ board.summary.late }}</p></article>
    </div>
    <section class="panel p-5">
      <p v-if="!board?.rows?.length" class="text-muted">{{ t('empty') }}</p>
      <div v-for="row in board?.rows || []" :key="row.user.uuid" class="table-row md:grid-cols-[1.3fr_.8fr_.8fr_.6fr_.6fr]">
        <div>
          <p class="font-medium">{{ row.user.name }}</p>
          <p class="text-xs text-muted">{{ row.user.job_title || row.department?.name }}</p>
        </div>
        <span class="text-sm">{{ t(`status_${row.status}`) }}</span>
        <span class="text-sm text-muted">{{ row.day?.check_in_local || '—' }} – {{ row.day?.check_out_local || '—' }}</span>
        <span class="text-sm">{{ row.day?.late_minutes ?? 0 }} {{ t('minutes') }}</span>
        <span class="text-sm">{{ row.day?.worked_minutes ?? 0 }} {{ t('minutes') }}</span>
      </div>
    </section>
  </div>
</template>
