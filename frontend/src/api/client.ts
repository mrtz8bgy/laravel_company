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

  const response = await fetch(`/api/v1${path}`, { ...options, headers })
  const payload = await response.json().catch(() => ({
    success: false,
    data: null,
    message: 'Unexpected response',
    errors: [],
  }))

  if (response.status === 401 && !path.startsWith('/auth/login') && !path.startsWith('/onboarding/company')) {
    setToken(null)
    if (!window.location.pathname.startsWith('/login')) {
      window.location.assign('/login')
    }
  }

  if (!response.ok || payload.success === false) {
    const errors = Array.isArray(payload.errors) ? {} : (payload.errors ?? {})
    throw new ApiError(payload.message || 'Request failed', response.status, errors)
  }

  return payload as Envelope<T>
}
