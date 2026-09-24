<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, ApiError } from '../api/client'
import { useAuthStore } from '../stores/auth'
import { useUiStore } from '../stores/ui'

const auth = useAuthStore()
const ui = useUiStore()
const { t } = useI18n()
const rows = ref<any[]>([])
const current = ref<any>(null)
const form = reactive({ title: '', body: '', visibility: 'company' })

async function load() {
  rows.value = (await api<any[]>('/documents')).data
}

async function open(uuid: string) {
  current.value = (await api<any>(`/documents/${uuid}`)).data
}

async function save() {
  try {
    await api('/documents', { method: 'POST', body: JSON.stringify(form) })
    form.title = ''
    form.body = ''
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
    <p class="kicker">{{ t('navCompany') }}</p>
    <h1 class="mt-2 text-3xl font-semibold">{{ t('documents') }}</h1>
    <div class="mt-6 grid gap-4 lg:grid-cols-[.8fr_1.2fr]">
      <section class="panel p-5">
        <button v-for="row in rows" :key="row.uuid" class="flex w-full items-center justify-between border-b border-line py-3 text-start" @click="open(row.uuid)">
          <span class="font-medium">{{ row.title }}</span>
          <span class="badge">{{ t(`visibility_${row.visibility}`) }}</span>
        </button>
        <p v-if="!rows.length" class="text-sm text-muted">{{ t('empty') }}</p>
      </section>
      <section class="panel p-5">
        <article v-if="current">
          <h2 class="text-xl font-semibold">{{ current.title }}</h2>
          <p class="mt-3 whitespace-pre-wrap text-sm leading-7">{{ current.body }}</p>
        </article>
        <form v-if="auth.can('documents.manage')" class="mt-5 space-y-3" @submit.prevent="save">
          <label class="field"><span>{{ t('name') }}</span><input v-model="form.title" required /></label>
          <label class="field"><span>{{ t('description') }}</span><textarea v-model="form.body" rows="5" required /></label>
          <label class="field">
            <span>{{ t('visibility') }}</span>
            <select v-model="form.visibility">
              <option value="company">{{ t('visibility_company') }}</option>
              <option value="private">{{ t('visibility_private') }}</option>
            </select>
          </label>
          <button class="btn btn-primary">{{ t('create') }}</button>
        </form>
      </section>
    </div>
  </div>
</template>
