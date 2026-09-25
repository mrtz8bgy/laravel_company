<script setup lang="ts">
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useAuthStore } from '../stores/auth'
import { applyLocale } from '../i18n'

const auth = useAuthStore()
const route = useRoute()
const router = useRouter()
const { t, locale } = useI18n()
const guest = computed(() => route.path === '/portal/register')

const links = [
  { to: '/portal', label: 'personalPage' },
  { to: '/portal/profile', label: 'myProfile' },
  { to: '/portal/orders', label: 'myOrders' },
  { to: '/portal/messages', label: 'myMessages' },
  { to: '/portal/tickets', label: 'myTickets' },
]

async function logout() {
  await auth.logout()
  router.push('/login')
}
</script>

<template>
  <div class="min-h-screen">
    <header class="border-b border-white/10 bg-ink text-white">
      <div class="mx-auto flex w-full max-w-5xl flex-wrap items-center justify-between gap-3 px-4 py-4">
        <div>
          <p class="kicker !text-brass">{{ t('customerPortal') }}</p>
          <p class="mt-1 text-sm text-white/70">{{ auth.company?.name || t('portalHint') }}</p>
        </div>
        <div class="flex items-center gap-2">
          <button class="btn btn-ghost !border-white/15 !bg-transparent !text-white" type="button" @click="applyLocale(locale === 'fa' ? 'en' : 'fa')">{{ t('language') }}</button>
          <button v-if="!guest && auth.token" class="btn btn-ghost !border-white/15 !bg-transparent !text-white" type="button" @click="logout">{{ t('logout') }}</button>
          <router-link v-else class="btn btn-ghost !border-white/15 !bg-transparent !text-white" to="/login">{{ t('login') }}</router-link>
        </div>
      </div>
      <nav v-if="!guest && auth.token" class="mx-auto flex w-full max-w-5xl gap-2 px-4 pb-4">
        <router-link v-for="link in links" :key="link.to" :to="link.to" class="rounded-full border border-white/15 px-4 py-1.5 text-sm text-white/80">
          {{ t(link.label) }}
        </router-link>
      </nav>
    </header>
    <main class="mx-auto w-full max-w-5xl px-4 py-8">
      <router-view />
    </main>
  </div>
</template>
