'use client'

import { Eye, EyeOff, Lock, User } from 'lucide-react'
import { useActionState, useState } from 'react'
import { useFormStatus } from 'react-dom'
import { loginAction } from '@/app/login/actions'

function SubmitButton() {
  const { pending } = useFormStatus()

  return (
    <button type="submit" disabled={pending} className="btn-primary w-full">
      {pending ? 'Memeriksa akun...' : 'Masuk'}
    </button>
  )
}

export function LoginForm() {
  const [state, formAction] = useActionState(loginAction, { error: null })
  const [showPassword, setShowPassword] = useState(false)

  return (
    <form action={formAction} className="mt-8 space-y-5">
      <label className="block">
        <span className="mb-2 block text-xs font-semibold uppercase tracking-[0.16em] text-text-muted">
          Username
        </span>
        <div className="relative">
          <User
            className="pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 text-text-muted"
            size={18}
          />
          <input
            className="input pl-11"
            type="text"
            name="username"
            placeholder="Username PT"
            autoComplete="username"
            spellCheck={false}
          />
        </div>
      </label>

      <label className="block">
        <span className="mb-2 block text-xs font-semibold uppercase tracking-[0.16em] text-text-muted">
          Password
        </span>
        <div className="relative">
          <Lock
            className="pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 text-text-muted"
            size={18}
          />
          <input
            className="input px-11"
            type={showPassword ? 'text' : 'password'}
            name="password"
            placeholder="Password"
            autoComplete="current-password"
          />
          <button
            type="button"
            onClick={() => setShowPassword((visible) => !visible)}
            className="absolute right-3 top-1/2 -translate-y-1/2 rounded-lg p-1.5 text-text-muted transition hover:bg-surface hover:text-text-primary"
            aria-label={
              showPassword ? 'Sembunyikan password' : 'Tampilkan password'
            }
          >
            {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
          </button>
        </div>
      </label>

      {state.error && (
        <div
          role="alert"
          className="rounded-xl border border-danger/30 bg-danger/10 px-4 py-3 text-sm leading-6 text-danger"
        >
          {state.error}
        </div>
      )}

      <SubmitButton />
    </form>
  )
}
