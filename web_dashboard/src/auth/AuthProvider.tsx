import { useCallback, useEffect, useMemo, useState } from 'react'
import type { ReactNode } from 'react'
import { loginRequest } from '../api/auth'
import {
  TOKEN_STORAGE_KEY,
  UNAUTHORIZED_EVENT,
  USER_STORAGE_KEY,
} from '../api/client'
import type { AuthUser } from '../types/api'
import { AuthContext } from './auth-context'

interface AuthSession {
  token: string | null
  user: AuthUser | null
}

function readStoredUser(): AuthUser | null {
  const raw = localStorage.getItem(USER_STORAGE_KEY)
  if (!raw) return null

  try {
    const parsed = JSON.parse(raw) as Partial<AuthUser>

    if (
      typeof parsed.user_id !== 'number' ||
      typeof parsed.name !== 'string' ||
      parsed.role !== 'pt'
    ) {
      return null
    }

    return {
      user_id: parsed.user_id,
      name: parsed.name,
      role: 'pt',
    }
  } catch {
    return null
  }
}

function readStoredSession(): AuthSession {
  const token = localStorage.getItem(TOKEN_STORAGE_KEY)
  const user = readStoredUser()

  if (!token || !user) {
    localStorage.removeItem(TOKEN_STORAGE_KEY)
    localStorage.removeItem(USER_STORAGE_KEY)
    return { token: null, user: null }
  }

  return { token, user }
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<AuthSession>(() => readStoredSession())

  const clearSession = useCallback(() => {
    localStorage.removeItem(TOKEN_STORAGE_KEY)
    localStorage.removeItem(USER_STORAGE_KEY)
    setSession({ token: null, user: null })
  }, [])

  useEffect(() => {
    const handleUnauthorized = () => clearSession()
    const handleStorage = (event: StorageEvent) => {
      if (event.key === TOKEN_STORAGE_KEY || event.key === USER_STORAGE_KEY) {
        setSession(readStoredSession())
      }
    }

    window.addEventListener(UNAUTHORIZED_EVENT, handleUnauthorized)
    window.addEventListener('storage', handleStorage)

    return () => {
      window.removeEventListener(UNAUTHORIZED_EVENT, handleUnauthorized)
      window.removeEventListener('storage', handleStorage)
    }
  }, [clearSession])

  const login = useCallback(async (username: string, password: string) => {
    const result = await loginRequest(username.trim(), password)

    if (result.user.role !== 'pt') {
      throw new Error('Akun ini bukan Personal Trainer. Dashboard web hanya untuk role PT.')
    }

    localStorage.setItem(TOKEN_STORAGE_KEY, result.token)
    localStorage.setItem(USER_STORAGE_KEY, JSON.stringify(result.user))
    setSession({ token: result.token, user: result.user })
  }, [])

  const logout = useCallback(() => {
    clearSession()
  }, [clearSession])

  const value = useMemo(
    () => ({
      user: session.user,
      isAuthenticated: Boolean(session.token && session.user),
      login,
      logout,
    }),
    [login, logout, session],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}
