import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import { appBasePath } from './api/client'
import router from './router'
import { i18n } from './i18n'
import './styles.css'

function shouldLeaveShellUrl(): boolean {
  if (import.meta.env.DEV) return false
  const root = appBasePath()
  const here = window.location.pathname.replace(/\/+$/, '') || '/'
  const messy = [`${root}/index.php`, `${root}/app`, `${root}/app/index.html`]
  if (!messy.includes(here)) return false
  const next = `${root}/` || '/'
  window.location.replace(next + window.location.search + window.location.hash)
  return true
}

if (!shouldLeaveShellUrl()) {
  createApp(App).use(createPinia()).use(router).use(i18n).mount('#app')
}
