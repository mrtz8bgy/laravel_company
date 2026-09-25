<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api } from '../api/client'
import { useDate } from '../lib/date'

const { t } = useI18n()
const { formatDateTime } = useDate()
const rows = ref<any[]>([])

onMounted(async () => {
  rows.value = (await api<any[]>('/activity-logs')).data
})
</script>

<template>
  <div>
    <p class="text-sm text-copper">{{ t('activity') }}</p>
    <h1 class="mb-5 text-3xl font-semibold">{{ t('activity') }}</h1>
    <section class="panel p-5">
      <p v-if="!rows.length" class="text-muted">{{ t('empty') }}</p>
      <article v-for="row in rows" :key="row.id" class="table-row md:grid-cols-[auto_1fr_auto]">
        <span class="badge">{{ row.action }}</span>
        <div>
          <p class="text-sm">{{ row.user?.name || '—' }} · {{ row.entity_type }}</p>
          <p class="text-xs text-muted">{{ row.description }}</p>
        </div>
        <span class="text-xs text-muted">{{ row.ip }}</span>
      </article>
    </section>
  </div>
</template>
