<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api } from '../api/client'

const { t } = useI18n()
const cards = ref<{ key: string; value: number }[]>([])

onMounted(async () => {
  cards.value = (await api<{ key: string; value: number }[]>('/analytics/overview')).data
})
</script>

<template>
  <div>
    <p class="kicker">{{ t('navBusiness') }}</p>
    <h1 class="mt-2 text-3xl font-semibold">{{ t('analytics') }}</h1>
    <p class="mt-2 max-w-2xl text-sm text-muted">{{ t('sensitiveHidden') }}</p>
    <div class="mt-6 grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
      <article v-for="card in cards" :key="card.key" class="panel stat">
        <p class="text-sm text-muted">{{ t(`metric_${card.key}`) }}</p>
        <strong>{{ card.value }}</strong>
      </article>
    </div>
  </div>
</template>
