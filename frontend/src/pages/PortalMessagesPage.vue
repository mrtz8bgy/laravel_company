<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, ApiError } from '../api/client'
import { useDate } from '../lib/date'
import { useUiStore } from '../stores/ui'

type Thread = {
  uuid: string
  desk: string
  subject: string
  status: string
  updated_at?: string
  messages?: { body: string; is_staff: boolean; created_at: string; author?: { name: string } | null }[]
}

const ui = useUiStore()
const { t } = useI18n()
const dates = useDate()
const threads = ref<Thread[]>([])
const selected = ref<Thread | null>(null)
const desk = ref('sales')
const subject = ref('')
const body = ref('')
const reply = ref('')
const locked = ref(false)
const loading = ref(false)

async function load() {
  const me = await api<{ customer: { status: string } }>('/portal/me')
  locked.value = me.data.customer.status !== 'active'
  threads.value = (await api<Thread[]>('/portal/threads')).data
}

async function open(thread: Thread) {
  selected.value = (await api<Thread>('/portal/threads/' + thread.uuid)).data
}

onMounted(load)

async function send() {
  loading.value = true
  try {
    await api('/portal/threads', { method: 'POST', body: JSON.stringify({ desk: desk.value, subject: subject.value, body: body.value }) })
    subject.value = ''
    body.value = ''
    ui.toast(t('sendMessage'))
    await load()
  } catch (err) {
    ui.toast(err instanceof ApiError ? err.message : 'Error', 'bad')
  } finally {
    loading.value = false
  }
}

async function sendReply() {
  if (!selected.value) return
  loading.value = true
  try {
    selected.value = (await api<Thread>('/portal/threads/' + selected.value.uuid + '/replies', {
      method: 'POST',
      body: JSON.stringify({ body: reply.value }),
    })).data
    reply.value = ''
    await load()
  } catch (err) {
    ui.toast(err instanceof ApiError ? err.message : 'Error', 'bad')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="grid gap-5 lg:grid-cols-[1fr_.9fr]">
    <section class="panel p-6">
      <p class="kicker">{{ t('myMessages') }}</p>
      <h1 class="mt-2 text-3xl font-semibold">{{ t('sendMessage') }}</h1>
      <p v-if="locked" class="mt-4 rounded-2xl bg-copper-soft px-4 py-3 text-sm">{{ t('awaitingApproval') }}</p>
      <form v-else class="mt-5 grid gap-3" @submit.prevent="send">
        <label class="field">
          <span>{{ t('desk') }}</span>
          <select v-model="desk">
            <option value="sales">{{ t('desk_sales') }}</option>
            <option value="support">{{ t('desk_support') }}</option>
            <option value="management">{{ t('desk_management') }}</option>
          </select>
        </label>
        <label class="field"><span>{{ t('subject') }}</span><input v-model="subject" required /></label>
        <label class="field"><span>{{ t('messageBody') }}</span><textarea v-model="body" rows="4" required /></label>
        <button class="btn btn-primary w-fit" :disabled="loading">{{ t('sendMessage') }}</button>
      </form>
      <div class="mt-6 grid gap-2">
        <button v-for="thread in threads" :key="thread.uuid" type="button" class="rounded-2xl border border-line px-4 py-3 text-start" @click="open(thread)">
          <span class="badge">{{ t('desk_' + thread.desk) }}</span>
          <span class="badge ms-2">{{ t('status_' + thread.status) }}</span>
          <p class="mt-2 font-medium">{{ thread.subject }}</p>
        </button>
        <p v-if="!threads.length" class="text-sm text-muted">{{ t('noRows') }}</p>
      </div>
    </section>
    <section v-if="selected" class="panel p-6">
      <h2 class="font-semibold">{{ selected.subject }}</h2>
      <div class="mt-4 grid gap-3">
        <article v-for="(message, index) in selected.messages" :key="index" class="rounded-2xl px-4 py-3" :class="message.is_staff ? 'bg-mint' : 'bg-copper-soft'">
          <p class="text-xs text-muted">{{ message.author?.name }} · {{ dates.formatDateTime(message.created_at) }}</p>
          <p class="mt-1 whitespace-pre-wrap text-sm">{{ message.body }}</p>
        </article>
      </div>
      <form v-if="selected.status !== 'closed'" class="mt-4 grid gap-3" @submit.prevent="sendReply">
        <label class="field"><span>{{ t('reply') }}</span><textarea v-model="reply" rows="3" required /></label>
        <button class="btn btn-primary w-fit" :disabled="loading">{{ t('reply') }}</button>
      </form>
    </section>
  </div>
</template>
