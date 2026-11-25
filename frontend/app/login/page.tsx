import { Activity, BarChart3, ShieldCheck, Sparkles } from 'lucide-react'
import type { Metadata } from 'next'
import { redirect } from 'next/navigation'
import { LoginForm } from '@/components/auth/login-form'
import { getSession } from '@/lib/session'

export const metadata: Metadata = {
  title: 'Login PT',
}

const highlights = [
  {
    label: 'Review AI',
    description: 'Setujui atau sesuaikan rencana.',
    icon: Sparkles,
  },
  {
    label: 'Progres',
    description: 'Pantau berat dan langkah.',
    icon: BarChart3,
  },
  {
    label: 'Terkontrol',
    description: 'Hanya klien bimbingan PT.',
    icon: ShieldCheck,
  },
]

export default async function LoginPage() {
  const session = await getSession()
  if (session) redirect('/')

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
                <p className="text-sm font-semibold tracking-wide">
                  HEALTHMAXXING
                </p>
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

            <LoginForm />

            <div className="mt-6 rounded-xl border border-border bg-surface-alt/60 px-4 py-3 text-xs leading-5 text-text-muted">
              <span className="font-semibold text-text-secondary">
                Akun demo:
              </span>{' '}
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
