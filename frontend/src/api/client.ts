export type FieldErrors = Record<string, string[]>

export type Envelope<T> = {
  success: boolean
  data: T
  message: string | null
  errors: FieldErrors | []
  meta?: {
    current_page: number
    per_page: number
    total: number
    last_page: number
  }
}

export class ApiError extends Error {
  status: number
  errors: FieldErrors

  constructor(message: string, status: number, errors: FieldErrors = {}) {
    super(message)
    this.status = status
    this.errors = errors
  }
}

const TOKEN_KEY = 'vcos.token'

declare global {
  interface Window {
    __VCOS_BASE__?: string
  }
}

/**
 * Directory that contains backend/public, without a trailing slash.
 * Empty when the app is served from the host root or from the Vite dev server.
 */
export function appBasePath(): string {
  if (typeof window === 'undefined') return ''
  const injected = window.__VCOS_BASE__
  if (typeof injected === 'string' && injected !== '') return injected.replace(/\/$/, '')
  if (import.meta.env.DEV) return ''
  try {
    const path = new URL(import.meta.url).pathname
    const marker = '/app/assets/'
    const index = path.indexOf(marker)
    if (index > 0) return path.slice(0, index)
  } catch {
    /* The dev server and tests have no built asset URL. */
  }
  return ''
}

export function appHref(path: string): string {
  const suffix = path.startsWith('/') ? path : `/${path}`
  const root = appBasePath()
  return root ? `${root}${suffix}` : suffix
}

/** XAMPP serves Laravel from htdocs, not from Vite's port. */
export function apiOrigin(): string {
  const configured = String(import.meta.env.VITE_API_BASE ?? '').trim().replace(/\/$/, '')
  if (import.meta.env.DEV) {
    if (configured) return configured
    return xamppFallback()
  }
  const base = appBasePath()
  if (base) return base
  if (configured) return configured
  return xamppFallback()
}

function xamppFallback(): string {
  if (typeof window !== 'undefined' && ['5173', '4173'].includes(window.location.port)) {
    const host = window.location.hostname || '127.0.0.1'
    return `${window.location.protocol}//${host}/laravel_company/backend/public`
  }
  return ''
}

export function getToken(): string | null {
  return localStorage.getItem(TOKEN_KEY)
}

export function setToken(token: string | null): void {
  if (token) localStorage.setItem(TOKEN_KEY, token)
  else localStorage.removeItem(TOKEN_KEY)
}

export async function api<T>(path: string, options: RequestInit = {}): Promise<Envelope<T>> {
  const headers = new Headers(options.headers)
  headers.set('Accept', 'application/json')
  if (options.body && !(options.body instanceof FormData) && !headers.has('Content-Type')) {
    headers.set('Content-Type', 'application/json')
  }
  const token = getToken()
  if (token) headers.set('Authorization', `Bearer ${token}`)

  const url = `${apiOrigin()}/api/v1${path}`
  let response: Response
  try {
    response = await fetch(url, { ...options, headers })
  } catch {
    throw new ApiError('اتصال به سرور برقرار نشد. Apache و آدرس backend/public را بررسی کنید.', 0)
  }

  const text = await response.text()
  let payload: Envelope<T>
  try {
    payload = JSON.parse(text) as Envelope<T>
  } catch {
    throw new ApiError(
      `پاسخ سرور JSON نیست (${response.status}). فرانت به ${url} وصل نشد.`,
      response.status,
    )
  }

  if (response.status === 401 && !path.startsWith('/auth/login') && !path.startsWith('/onboarding/company')) {
    setToken(null)
    const loginPath = appHref('/login')
    if (window.location.pathname !== loginPath) {
      window.location.assign(loginPath)
    }
  }

  if (!response.ok || payload.success === false) {
    const errors = Array.isArray(payload.errors) ? {} : (payload.errors ?? {})
    throw new ApiError(payload.message || 'Request failed', response.status, errors)
  }

  return payload as Envelope<T>
}
