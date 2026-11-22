import type { LoginResponse } from '../types/api'
import { apiRequest } from './client'

export function loginRequest(username: string, password: string) {
  return apiRequest<LoginResponse>('/auth/login', {
    method: 'POST',
    body: JSON.stringify({ username, password }),
  })
}

export function logoutRequest() {
  return apiRequest<{ message: string }>('/auth/logout', { method: 'POST' })
}
