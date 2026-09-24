import { defineStore } from 'pinia'

type Toast = { id: number; text: string; tone: 'ok' | 'bad' }

export const useUiStore = defineStore('ui', {
  state: () => ({
    toasts: [] as Toast[],
    palette: false,
    sidebar: false,
  }),
  actions: {
    toast(text: string, tone: Toast['tone'] = 'ok') {
      const id = Date.now() + Math.random()
      this.toasts.push({ id, text, tone })
      setTimeout(() => {
        this.toasts = this.toasts.filter((item) => item.id !== id)
      }, 3200)
    },
  },
})
