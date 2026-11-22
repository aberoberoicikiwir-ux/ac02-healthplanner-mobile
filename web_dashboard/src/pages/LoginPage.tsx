import { useState } from 'react'
import type { FormEvent } from 'react'
import {
  Activity,
  BarChart3,
  Eye,
  EyeOff,
  Lock,
  ShieldCheck,
  Sparkles,
  User,
} from 'lucide-react'
import { Navigate, useLocation, useNavigate } from 'react-router-dom'
import { useAuth } from '../auth/auth-context'
import { getErrorMessage } from '../utils/errors'

const highlights = [
  { label: 'Review AI', description: 'Setujui atau sesuaikan rencana.', icon: Sparkles },
  { label: 'Progres', description: 'Pantau berat dan langkah.', icon: BarChart3 },
  { label: 'Terkontrol', description: 'Hanya klien bimbingan PT.', icon: ShieldCheck },
]

export function LoginPage() {
  const { isAuthenticated, login } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [isSubmitting, setIsSubmitting] = useState(false)

  if (isAuthenticated) {
    return <Navigate to="/" replace />
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setError(null)

    if (!username.trim() || !password) {
      setError('Username dan password wajib diisi.')
      return
    }

    setIsSubmitting(true)

    try {
      await login(username, password)
      const from = (location.state as { from?: string } | null)?.from
      navigate(from && from !== '/login' ? from : '/', { replace: true })
    } catch (submitError) {
      setError(getErrorMessage(submitError))
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <div className="relative min-h-screen overflow-hidden bg-background text-text-primary">
      <div className="app-glow pointer-events-none absolute inset-0" />

      <div className="relative mx-auto grid min-h-screen max-w-7xl items-center gap-10 px-6 py-10 lg:grid-cols-[1.05fr_0.95fr] lg:px-10">
        <section className="hidden lg:block">
          <div className="max-w-xl">
            <div className="inline-flex items-center gap-3 rounded-full border border-border bg-surface/70 px-4 py-2 text-xs font-medium text-text-secondary backdrop-blur">
              <Activity size={16} className="text-accent" />
              HEALTHMAXXING · PT Dashboard
            </div>

            <h1 className="mt-8 text-5xl font-semibold leading-tight tracking-tight">
              Tinjau rencana.{' '}
              <span className="text-accent">Jaga progres.</span>
            </h1>
            <p className="mt-5 max-w-lg text-base leading-7 text-text-muted">
              Dashboard untuk Personal Trainer: pantau klien, lihat progres, dan
              setujui atau sesuaikan rencana mingguan sebelum sampai ke aplikasi
              klien.
            </p>

            <div className="mt-8 grid gap-3 sm:grid-cols-3">
              {highlights.map((item) => {
                const Icon = item.icon

                return (
                  <div
                    key={item.label}
                    className="rounded-2xl border border-border bg-surface/60 p-4 backdrop-blur"
                  >
                    <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary/15 text-accent">
                      <Icon size={18} />
                    </div>
                    <p className="mt-3 text-sm font-semibold">{item.label}</p>
                    <p className="mt-1 text-xs leading-5 text-text-muted">
                      {item.description}
                    </p>
                  </div>
                )
              })}
            </div>
          </div>
        </section>

        <section className="mx-auto w-full max-w-md">
          <div className="rounded-3xl border border-border bg-surface/90 p-6 shadow-2xl shadow-black/30 backdrop-blur sm:p-8">
            <div className="flex items-center gap-3 lg:hidden">
              <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary/15 text-accent ring-1 ring-accent/20">
                <Activity size={22} />
              </div>
              <div>
                <p className="text-sm font-semibold tracking-wide">HEALTHMAXXING</p>
                <p className="text-xs text-text-muted">PT Dashboard</p>
              </div>
            </div>

            <div className="mt-8 lg:mt-0">
              <p className="text-xs font-semibold uppercase tracking-[0.22em] text-accent">
                Portal Personal Trainer
              </p>
              <h2 className="mt-2 text-3xl font-semibold tracking-tight">
                Masuk ke dashboard
              </h2>
              <p className="mt-2 text-sm leading-6 text-text-muted">
                Gunakan akun PT yang sudah terhubung dengan klien.
              </p>
            </div>

            <form onSubmit={handleSubmit} className="mt-8 space-y-5">
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
                    value={username}
                    onChange={(event) => setUsername(event.target.value)}
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
                    value={password}
                    onChange={(event) => setPassword(event.target.value)}
                    placeholder="Password"
                    autoComplete="current-password"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword((visible) => !visible)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 rounded-lg p-1.5 text-text-muted transition hover:bg-surface hover:text-text-primary"
                    aria-label={showPassword ? 'Sembunyikan password' : 'Tampilkan password'}
                  >
                    {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                  </button>
                </div>
              </label>

              {error && (
                <div
                  role="alert"
                  className="rounded-xl border border-danger/30 bg-danger/10 px-4 py-3 text-sm leading-6 text-danger"
                >
                  {error}
                </div>
              )}

              <button
                type="submit"
                disabled={isSubmitting}
                className="btn-primary w-full"
              >
                {isSubmitting ? 'Memeriksa akun...' : 'Masuk'}
              </button>
            </form>

            <div className="mt-6 rounded-xl border border-border bg-surface-alt/60 px-4 py-3 text-xs leading-5 text-text-muted">
              <span className="font-semibold text-text-secondary">Akun demo:</span>{' '}
              <code className="rounded bg-surface px-1.5 py-0.5 text-text-secondary">
                pt_demo
              </code>{' '}
              /{' '}
              <code className="rounded bg-surface px-1.5 py-0.5 text-text-secondary">
                demo12345
              </code>
            </div>
          </div>

          <p className="mt-4 text-center text-xs text-text-muted">
            Hanya role PT. Akun klien akan ditolak.
          </p>
        </section>
      </div>
    </div>
  )
}
