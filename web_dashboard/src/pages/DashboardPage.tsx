import {
  ArrowRight,
  Bell,
  CalendarDays,
  ClipboardCheck,
  Users,
} from 'lucide-react'
import { Link } from 'react-router-dom'
import { useAuth } from '../auth/auth-context'

const stats = [
  {
    label: 'Klien aktif',
    value: '—',
    hint: 'Fase 2',
    icon: Users,
  },
  {
    label: 'Menunggu review',
    value: '—',
    hint: 'Fase 4',
    icon: ClipboardCheck,
  },
  {
    label: 'Rencana minggu ini',
    value: '—',
    hint: 'Fase 4',
    icon: CalendarDays,
  },
]

export function DashboardPage() {
  const { user } = useAuth()

  return (
    <div className="mx-auto max-w-6xl space-y-6">
      <section className="panel overflow-hidden p-6 sm:p-8">
        <div className="flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.22em] text-accent">
              Dashboard PT
            </p>
            <h2 className="mt-2 text-2xl font-semibold tracking-tight sm:text-3xl">
              Selamat datang, {user?.name ?? 'Personal Trainer'}.
            </h2>
            <p className="mt-3 max-w-2xl text-sm leading-6 text-text-muted">
              Fondasi dashboard sudah siap: login PT, proteksi route, API client,
              dan layout. Daftar klien dan grafik progres masuk di fase berikutnya.
            </p>
          </div>
          <div className="rounded-2xl border border-accent/20 bg-accent/10 px-4 py-3 text-sm font-medium text-accent">
            Phase 0–1 selesai
          </div>
        </div>
      </section>

      <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
        {stats.map((stat) => {
          const Icon = stat.icon

          return (
            <div key={stat.label} className="panel p-5">
              <div className="flex items-start justify-between gap-4">
                <div>
                  <p className="text-sm text-text-muted">{stat.label}</p>
                  <p className="mt-2 text-3xl font-semibold">{stat.value}</p>
                </div>
                <div className="rounded-xl bg-primary/15 p-3 text-accent">
                  <Icon size={20} />
                </div>
              </div>
              <p className="mt-4 text-xs text-text-muted">{stat.hint}</p>
            </div>
          )
        })}
      </section>

      <section className="grid gap-4 lg:grid-cols-2">
        <div className="panel p-6">
          <div className="flex items-center gap-3">
            <div className="rounded-xl bg-success/10 p-2.5 text-success">
              <ClipboardCheck size={18} />
            </div>
            <div>
              <h3 className="font-semibold">Sudah tersedia</h3>
              <p className="text-xs text-text-muted">Fondasi web dashboard</p>
            </div>
          </div>

          <ul className="mt-5 space-y-3 text-sm text-text-secondary">
            <li>Login PT dan penolakan role klien.</li>
            <li>Token, logout, dan redirect otomatis saat 401.</li>
            <li>Layout responsif dan tema gelap yang konsisten.</li>
            <li>API client dengan proxy ke backend lokal.</li>
          </ul>
        </div>

        <div className="panel p-6">
          <div className="flex items-center gap-3">
            <div className="rounded-xl bg-warning/10 p-2.5 text-warning">
              <Bell size={18} />
            </div>
            <div>
              <h3 className="font-semibold">Berikutnya</h3>
              <p className="text-xs text-text-muted">Fase 2–4</p>
            </div>
          </div>

          <ul className="mt-5 space-y-3 text-sm text-text-secondary">
            <li>Daftar klien aktif dan pencarian.</li>
            <li>Detail klien, grafik berat, dan langkah.</li>
            <li>Review AI, approve, dan override rencana.</li>
          </ul>

          <Link
            to="/notifications"
            className="mt-6 inline-flex items-center gap-2 text-sm font-semibold text-accent transition hover:text-accent/80"
          >
            Lihat halaman notifikasi
            <ArrowRight size={16} />
          </Link>
        </div>
      </section>
    </div>
  )
}
