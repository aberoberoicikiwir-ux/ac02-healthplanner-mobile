import 'server-only'
import { cookies } from 'next/headers'
import { redirect } from 'next/navigation'
import type { AuthUser } from '@/types/api'

export const TOKEN_COOKIE = 'hmx_token'
export const USER_COOKIE = 'hmx_user'

export interface Session {
  token: string
  user: AuthUser
}

function parseUser(value: string | undefined): AuthUser | null {
  if (!value) return null

  try {
    const user = JSON.parse(value) as Partial<AuthUser>
    if (
      typeof user.user_id !== 'number' ||
      typeof user.name !== 'string' ||
      user.role !== 'pt'
    ) {
      return null
    }
    return { user_id: user.user_id, name: user.name, role: 'pt' }
  } catch {
    return null
  }
}

export async function getSession(): Promise<Session | null> {
  const store = await cookies()
  const token = store.get(TOKEN_COOKIE)?.value
  const user = parseUser(store.get(USER_COOKIE)?.value)

  if (!token || !user) return null
  return { token, user }
}

export async function requireSession(): Promise<Session> {
  const session = await getSession()
  if (!session) redirect('/login')
  return session
}

export async function setSession(token: string, user: AuthUser) {
  const store = await cookies()
  const options = {
    httpOnly: true,
    sameSite: 'lax' as const,
    secure: process.env.NODE_ENV === 'production',
    path: '/',
    maxAge: 60 * 60 * 24 * 7,
  }

  store.set(TOKEN_COOKIE, token, options)
  store.set(USER_COOKIE, JSON.stringify(user), options)
}

export async function clearSession() {
  const store = await cookies()
  store.delete(TOKEN_COOKIE)
  store.delete(USER_COOKIE)
}
