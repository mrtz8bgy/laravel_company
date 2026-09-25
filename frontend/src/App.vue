<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useI18n } from 'vue-i18n'
import AppShell from './layouts/AppShell.vue'
import { useUiStore } from './stores/ui'

const route = useRoute()
const ui = useUiStore()
const { t } = useI18n()
const bare = computed(() => route.path.startsWith('/portal') || ['/login', '/forgot-password', '/reset-password', '/accept-invite', '/onboarding'].includes(route.path))
</script>

<template>
  <AppShell v-if="!bare" />
  <router-view v-else />
  <div class="pointer-events-none fixed bottom-4 start-4 z-50 flex w-[min(100%-2rem,22rem)] flex-col gap-2">
    <div
      v-for="toast in ui.toasts"
      :key="toast.id"
      class="pointer-events-auto rounded-2xl px-4 py-3 text-sm shadow-lg"
      :class="toast.tone === 'bad' ? 'bg-danger text-white' : 'bg-ink text-white'"
    >
      {{ toast.text || t('save') }}
    </div>
  </div>
</template>
