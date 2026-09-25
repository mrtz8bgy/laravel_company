import { defineStore } from 'pinia'
import { api, getToken, setToken } from '../api/client'

export type AuthUser = {
  uuid: string
  name: string
  email: string
  phone?: string | null
  locale: string
  timezone?: string | null
  job_title?: string | null
  is_owner?: boolean
  status: string
  department?: { uuid: string; name: string; slug?: string } | null
}

export type Company = {
  uuid: string
  name: string
  legal_name?: string | null
  slug: string
  timezone: string
  locale: string
  calendar?: string
  status: string
  onboarded_at?: string | null
  onboarding?: Record<string, boolean>
}

type SessionPayload = {
  token?: string
  user: AuthUser
  company: Company | null
  permissions: string[]
  roles: { uuid: string; name: string; slug: string }[]
  features: Record<string, boolean>
  onboarding?: Record<string, boolean> | null
  requires_company?: boolean
  companies?: { uuid: string; name: string; job_title?: string | null }[]
}

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: getToken() as string | null,
    user: null as AuthUser | null,
    company: null as Company | null,
    permissions: [] as string[],
    roles: [] as SessionPayload['roles'],
    features: {} as Record<string, boolean>,
    onboarding: null as Record<string, boolean> | null,
    ready: false,
  }),
  getters: {
    can: (state) => (permission: string) => state.permissions.includes(permission),
    feature: (state) => (key: string) => state.features?.[key] === true,
    onboarded: (state) => Boolean(state.onboarding?.completed || state.company?.onboarded_at),
    isCustomer: (state) => state.roles.some((role) => role.slug === 'client') && !state.permissions.includes('company.view'),
  },
  actions: {
    apply(payload: SessionPayload) {
      if (payload.token) {
        this.token = payload.token
        setToken(payload.token)
      }
      this.user = payload.user
      this.company = payload.company
      this.permissions = payload.permissions ?? []
      this.roles = payload.roles ?? []
      this.features = payload.features ?? {}
      this.onboarding = payload.onboarding ?? payload.company?.onboarding ?? null
    },
    async login(email: string, password: string, companyUuid?: string) {
      const body: Record<string, string> = { email, password }
      if (companyUuid) body.company_uuid = companyUuid
      const response = await api<SessionPayload>('/auth/login', {
        method: 'POST',
        body: JSON.stringify(body),
      })
      if (response.data.requires_company) return response.data
      this.apply(response.data)
      return response.data
    },
    async fetchMe() {
      if (!getToken()) {
        this.ready = true
        return
      }
      try {
        const response = await api<SessionPayload>('/auth/me')
        this.apply(response.data)
      } catch {
        this.clear()
      } finally {
        this.ready = true
      }
    },
    async logout() {
      try {
        await api('/auth/logout', { method: 'POST' })
      } catch {
        /* token may already be gone */
      }
      this.clear()
    },
    clear() {
      this.token = null
      this.user = null
      this.company = null
      this.permissions = []
      this.roles = []
      this.onboarding = null
      setToken(null)
    },
  },
})
