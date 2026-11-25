'use server'

import { redirect } from 'next/navigation'
import { ApiError, loginRequest } from '@/lib/api'
import { clearSession, setSession } from '@/lib/session'

export interface LoginState {
  error: string | null
}

export async function loginAction(
  _previousState: LoginState,
  formData: FormData,
): Promise<LoginState> {
  const username = String(formData.get('username') ?? '').trim()
  const password = String(formData.get('password') ?? '')

  if (!username || !password) {
    return { error: 'Username dan password wajib diisi.' }
  }

  let shouldRedirect = false

  try {
    const result = await loginRequest(username, password)

    if (result.user.role !== 'pt') {
      return {
        error:
          'Akun ini bukan Personal Trainer. Dashboard web hanya untuk role PT.',
      }
    }

    await setSession(result.token, result.user)
    shouldRedirect = true
  } catch (error) {
    if (error instanceof ApiError) {
      return { error: error.message }
    }

    return { error: 'Terjadi kesalahan. Coba lagi.' }
  }

  if (shouldRedirect) {
    redirect('/')
  }

  return { error: null }
}

export async function logoutAction() {
  await clearSession()
  redirect('/login')
}
