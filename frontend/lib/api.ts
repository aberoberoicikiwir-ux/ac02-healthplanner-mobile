import 'server-only'
import type { LoginResponse } from '@/types/api'

const API_URL = (process.env.API_URL ?? 'http://localhost:3000/api').replace(
  /\/$/,
  '',
)

export class ApiError extends Error {
  readonly status: number
  readonly details: unknown

  constructor(status: number, message: string, details: unknown = null) {
    super(message)
    this.name = 'ApiError'
    this.status = status
    this.details = details
  }
}

async function parseBody(response: Response) {
  const text = await response.text()
  if (!text) return null

  try {
    return JSON.parse(text)
  } catch {
    return text
  }
}

export async function apiFetch<T>(
  path: string,
  token?: string,
  init: RequestInit = {},
): Promise<T> {
  const headers = new Headers(init.headers)
  headers.set('Accept', 'application/json')

  if (init.body && !headers.has('Content-Type')) {
    headers.set('Content-Type', 'application/json')
  }

  if (token) {
    headers.set('Authorization', `Bearer ${token}`)
  }

  const response = await fetch(
    `${API_URL}${path.startsWith('/') ? path : `/${path}`}`,
    {
      ...init,
      headers,
      cache: 'no-store',
    },
  )
  const body = await parseBody(response)

  if (!response.ok) {
    const message =
      body &&
      typeof body === 'object' &&
      'message' in body &&
      typeof body.message === 'string'
        ? body.message
        : `Permintaan gagal (${response.status}).`

    throw new ApiError(response.status, message, body)
  }

  return body as T
}

export function loginRequest(username: string, password: string) {
  return apiFetch<LoginResponse>('/auth/login', undefined, {
    method: 'POST',
    body: JSON.stringify({ username, password }),
  })
}
