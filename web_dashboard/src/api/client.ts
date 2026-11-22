import type { ApiErrorPayload } from '../types/api'

const API_BASE = (import.meta.env.VITE_API_BASE_URL ?? '/api').replace(/\/$/, '')

export const TOKEN_STORAGE_KEY = 'hmx_web_token'
export const USER_STORAGE_KEY = 'hmx_web_user'
export const UNAUTHORIZED_EVENT = 'hmx:unauthorized'

export class ApiError extends Error {
  readonly status: number
  readonly payload: ApiErrorPayload | null

  constructor(status: number, message: string, payload: ApiErrorPayload | null = null) {
    super(message)
    this.name = 'ApiError'
    this.status = status
    this.payload = payload
  }
}

function parseResponseBody(text: string): unknown {
  if (!text) return null

  try {
    return JSON.parse(text)
  } catch {
    return text
  }
}

export async function apiRequest<T>(path: string, options: RequestInit = {}): Promise<T> {
  const headers = new Headers(options.headers)
  headers.set('Accept', 'application/json')

  const token = localStorage.getItem(TOKEN_STORAGE_KEY)
  if (token) {
    headers.set('Authorization', `Bearer ${token}`)
  }

  if (options.body && !headers.has('Content-Type')) {
    headers.set('Content-Type', 'application/json')
  }

  const response = await fetch(`${API_BASE}${path.startsWith('/') ? path : `/${path}`}`, {
    ...options,
    headers,
  })

  const payload = parseResponseBody(await response.text())

  if (!response.ok) {
    if (response.status === 401) {
      window.dispatchEvent(new Event(UNAUTHORIZED_EVENT))
    }

    const message =
      payload &&
      typeof payload === 'object' &&
      'message' in payload &&
      typeof (payload as ApiErrorPayload).message === 'string'
        ? (payload as ApiErrorPayload).message!
        : `Permintaan gagal (${response.status}).`

    throw new ApiError(response.status, message, payload as ApiErrorPayload | null)
  }

  return payload as T
}
