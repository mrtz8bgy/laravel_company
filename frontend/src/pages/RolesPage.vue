<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, ApiError } from '../api/client'
import { useAuthStore } from '../stores/auth'
import { useUiStore } from '../stores/ui'

const auth = useAuthStore()
const ui = useUiStore()
const { t } = useI18n()
const roles = ref<any[]>([])
const catalog = ref<any[]>([])
const open = ref(false)
const editing = ref<any>(null)
const form = reactive({ name: '', description: '', permissions: [] as string[] })

const grouped = computed(() => {
  const map = new Map<string, any[]>()
  for (const permission of catalog.value) {
    const list = map.get(permission.module) || []
    list.push(permission)
    map.set(permission.module, list)
  }
  return [...map.entries()]
})

async function load() {
  roles.value = (await api<any[]>('/roles')).data
  if (auth.can('permissions.view')) catalog.value = (await api<any[]>('/permissions')).data
}

function start(role?: any) {
  editing.value = role ?? null
  form.name = role?.name ?? ''
  form.description = role?.description ?? ''
  form.permissions = [...(role?.permissions ?? [])]
  open.value = true
}

function toggle(name: string) {
  if (editing.value?.slug === 'company-owner') return
  form.permissions = form.permissions.includes(name)
    ? form.permissions.filter((item) => item !== name)
    : [...form.permissions, name]
}

async function save() {
  try {
    const payload = { name: form.name, description: form.description, permissions: form.permissions }
    if (editing.value) await api(`/roles/${editing.value.uuid}`, { method: 'PUT', body: JSON.stringify(payload) })
    else await api('/roles', { method: 'POST', body: JSON.stringify(payload) })
    open.value = false
    ui.toast(t('save'))
    await load()
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

async function remove(role: any) {
  if (!confirm(t('delete'))) return
  try {
    await api(`/roles/${role.uuid}`, { method: 'DELETE' })
    await load()
  } catch (error) {
    ui.toast(error instanceof ApiError ? error.message : 'Error', 'bad')
  }
}

onMounted(load)
</script>

<template>
  <div>
    <div class="mb-5 flex items-end justify-between">
      <div>
        <p class="text-sm text-copper">{{ t('access') }}</p>
        <h1 class="text-3xl font-semibold">{{ t('roles') }}</h1>
      </div>
      <button v-if="auth.can('roles.create')" class="btn btn-primary" @click="start()">{{ t('create') }}</button>
    </div>
    <div class="grid gap-3">
      <article v-for="role in roles" :key="role.uuid" class="panel flex items-start justify-between gap-4 p-5">
        <div>
          <div class="flex items-center gap-2">
            <h2 class="font-semibold">{{ role.name }}</h2>
            <span class="badge">{{ role.is_system ? t('system') : t('custom') }}</span>
          </div>
          <p class="mt-1 text-sm text-muted">{{ role.description }}</p>
          <p class="mt-3 text-xs text-faint">{{ role.permissions?.length || 0 }} {{ t('permissions') }}</p>
        </div>
        <div class="flex gap-2">
          <button v-if="auth.can('roles.update')" class="btn btn-ghost" @click="start(role)">{{ t('edit') }}</button>
          <button v-if="auth.can('roles.delete') && !role.is_system" class="btn btn-danger" @click="remove(role)">{{ t('delete') }}</button>
        </div>
      </article>
    </div>
    <div v-if="open" class="fixed inset-0 z-50 flex items-center justify-center bg-ink/40 p-4" @click.self="open = false">
      <form class="panel max-h-[90vh] w-full max-w-2xl overflow-auto p-6" @submit.prevent="save">
        <h2 class="mb-4 text-xl font-semibold">{{ editing ? t('edit') : t('create') }}</h2>
        <label class="field mb-3"><span>{{ t('name') }}</span><input v-model="form.name" required /></label>
        <label class="field mb-4"><span>{{ t('description') }}</span><input v-model="form.description" /></label>
        <div v-for="[module, permissions] in grouped" :key="module" class="mb-4">
          <p class="mb-2 text-sm font-semibold text-emerald">{{ module }}</p>
          <div class="grid gap-2 sm:grid-cols-2">
            <label v-for="permission in permissions" :key="permission.name" class="flex items-start gap-2 rounded-xl border border-line px-3 py-2 text-sm">
              <input type="checkbox" :checked="form.permissions.includes(permission.name)" @change="toggle(permission.name)" />
              <span>
                <span class="block font-medium">{{ permission.name }}</span>
                <span class="text-xs text-muted">{{ permission.description }}</span>
              </span>
            </label>
          </div>
        </div>
        <div class="flex justify-end gap-2">
          <button type="button" class="btn btn-ghost" @click="open = false">{{ t('cancel') }}</button>
          <button class="btn btn-primary">{{ t('save') }}</button>
        </div>
      </form>
    </div>
  </div>
</template>
