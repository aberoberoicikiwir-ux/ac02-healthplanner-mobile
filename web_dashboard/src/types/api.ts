export type UserRole = 'klien' | 'pt'

export interface AuthUser {
  user_id: number
  name: string
  role: UserRole
}

export interface LoginResponse {
  message: string
  token: string
  user: AuthUser
}

export interface ApiErrorPayload {
  message?: string
  details?: unknown
}

export interface PtClient {
  client_id: number
  status: string
  weight_current: number
  weight_target: number
  name: string
  email: string
}
