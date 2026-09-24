<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, ApiError } from '../api/client'
import { useAuthStore } from '../stores/auth'
import { useUiStore } from '../stores/ui'

const auth = useAuthStore()
const ui = useUiStore()
const { t } = useI18n()
const channels = ref<any[]>([])
const messages = ref<any[]>([])
const announcements = ref<any[]>([])
const active = ref('')
const body = ref('')
const notice = ref({ title: '', body: '' })

async function load() {
  channels.value = (await api<any[]>('/channels')).data
  announcements.value = (await api<any[]>('/announcements')).data
  if (!active.value && channels.value[0]) active.value = channels.value[0].uuid
  if (active.value) messages.value = (await api<any[]>(`/channels/${active.value}/messages`)).data
}

async function send() {
  try {
    await api(`/channels/${active.value}/messages`, { method: 'POST', body: JSON.stringify({ body: body.value }) })
    body.value = ''
    await load()
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

async function publish() {
  try {
    await api('/announcements', { method: 'POST', body: JSON.stringify(notice.value) })
    notice.value = { title: '', body: '' }
    ui.toast(t('save'))
    await load()
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

onMounted(load)
</script>

<template>
  <div>
    <p class="kicker">{{ t('navWork') }}</p>
    <h1 class="mt-2 text-3xl font-semibold">{{ t('inbox') }}</h1>
    <div class="mt-6 grid gap-4 lg:grid-cols-[.8fr_1.2fr]">
      <section class="panel p-5">
        <h2 class="font-semibold">{{ t('announcements') }}</h2>
        <article v-for="item in announcements" :key="item.uuid" class="mt-3 border-b border-line pb-3">
          <p class="font-medium">{{ item.title }}</p>
          <p class="mt-1 text-sm text-muted">{{ item.body }}</p>
        </article>
        <form v-if="auth.can('announcements.publish')" class="mt-4 space-y-3" @submit.prevent="publish">
          <label class="field"><span>{{ t('name') }}</span><input v-model="notice.title" required /></label>
          <label class="field"><span>{{ t('description') }}</span><textarea v-model="notice.body" rows="3" required /></label>
          <button class="btn btn-primary">{{ t('publish') }}</button>
        </form>
      </section>
      <section class="panel p-5">
        <div class="flex flex-wrap gap-2">
          <button v-for="channel in channels" :key="channel.uuid" class="btn" :class="active === channel.uuid ? 'btn-primary' : 'btn-ghost'" @click="active = channel.uuid; load()">
            {{ channel.name }}
          </button>
        </div>
        <div class="mt-4 space-y-3">
          <p v-if="!messages.length" class="text-sm text-muted">{{ t('empty') }}</p>
          <article v-for="message in messages" :key="message.uuid" class="rounded-2xl border border-line bg-white px-4 py-3">
            <p class="text-xs text-copper">{{ message.user?.name }}</p>
            <p class="mt-1 text-sm">{{ message.body }}</p>
          </article>
        </div>
        <form class="mt-4 flex gap-2" @submit.prevent="send">
          <input v-model="body" class="input" :placeholder="t('send')" required />
          <button class="btn btn-primary">{{ t('send') }}</button>
        </form>
      </section>
    </div>
  </div>
</template>
