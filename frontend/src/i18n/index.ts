import { createI18n } from 'vue-i18n'
import fa from './fa'
import en from './en'

const stored = localStorage.getItem('vcos.locale') || 'fa'

export const i18n = createI18n({
  legacy: false,
  locale: stored,
  fallbackLocale: 'en',
  messages: { fa, en },
})

export function applyLocale(locale: string) {
  i18n.global.locale.value = locale as 'fa' | 'en'
  localStorage.setItem('vcos.locale', locale)
  document.documentElement.lang = locale
  document.documentElement.dir = locale === 'fa' ? 'rtl' : 'ltr'
}

applyLocale(stored)
