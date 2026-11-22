import { useQuery } from '@tanstack/react-query'
import { useState } from 'react'
import {
  Activity,
  Bell,
  LayoutDashboard,
  LogOut,
  Menu,
  ShieldCheck,
  X,
} from 'lucide-react'
import { NavLink, Outlet, useLocation } from 'react-router-dom'
import { getNotifications } from '../api/notifications'
import { useAuth } from '../auth/auth-context'

const navigation = [
  { to: '/', label: 'Dashboard', icon: LayoutDashboard, end: true },
  { to: '/notifications', label: 'Notifikasi', icon: Bell, end: false },
]

const pageMeta: Record<string, { title: string; subtitle: string }> = {
  '/': {
    title: 'Dashboard',
    subtitle: 'Pantau klien dan rencana mingguan.',
  },
  '/notifications': {
    title: 'Notifikasi',
    subtitle: 'Pengingat dan hasil review rencana.',
  },
}

function classNames(...classes: Array<string | false | null | undefined>) {
  return classes.filter(Boolean).join(' ')
}

function getPageMeta(pathname: string) {
  if (pathname.startsWith('/clients/') && pathname.endsWith('/review')) {
    return {
      title: 'Review Rencana',
      subtitle: 'Tinjau, setujui, atau override rencana AI.',
    }
  }

  if (pathname.startsWith('/clients/')) {
    return {
      title: 'Detail Klien',
      subtitle: 'Profil, rencana, dan progres klien.',
    }
  }

  return pageMeta[pathname] ?? pageMeta['/']
}

export function AppLayout() {
  const { user, logout } = useAuth()
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const location = useLocation()
  const page = getPageMeta(location.pathname)
  const initial = (user?.name?.slice(0, 1) ?? 'P').toUpperCase()
  const notificationsQuery = useQuery({
    queryKey: ['notifications'],
    queryFn: getNotifications,
    staleTime: 30_000,
  })
  const unreadCount =
    notificationsQuery.data?.filter((item) => !item.is_read).length ?? 0

  return (
    <div className="min-h-screen bg-background text-text-primary">
      <div className="app-glow pointer-events-none fixed inset-0" />

      {sidebarOpen && (
        <button
          type="button"
          aria-label="Tutup menu"
          className="fixed inset-0 z-30 bg-black/60 backdrop-blur-sm lg:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      <aside
        className={classNames(
          'fixed inset-y-0 left-0 z-40 flex w-72 flex-col border-r border-border bg-surface/95 backdrop-blur-xl transition-transform duration-200 lg:translate-x-0',
          sidebarOpen ? 'translate-x-0' : '-translate-x-full',
        )}
      >
        <div className="flex h-20 items-center justify-between border-b border-border px-6">
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary/15 text-accent ring-1 ring-accent/20">
              <Activity size={22} />
            </div>
            <div>
              <p className="text-sm font-semibold tracking-wide text-text-primary">
                HEALTHMAXXING
              </p>
              <p className="text-xs text-text-muted">PT Dashboard</p>
            </div>
          </div>
          <button
            type="button"
            className="rounded-lg p-2 text-text-muted transition hover:bg-surface-alt hover:text-text-primary lg:hidden"
            onClick={() => setSidebarOpen(false)}
            aria-label="Tutup menu"
          >
            <X size={18} />
          </button>
        </div>

        <nav className="flex-1 space-y-2 px-4 py-6">
          <p className="px-3 pb-2 text-[11px] font-semibold uppercase tracking-[0.2em] text-text-muted">
            Menu
          </p>

          {navigation.map((item) => {
            const Icon = item.icon

            return (
              <NavLink
                key={item.to}
                to={item.to}
                end={item.end}
                onClick={() => setSidebarOpen(false)}
                className={({ isActive }) =>
                  classNames(
                    'flex items-center gap-3 rounded-xl px-3 py-3 text-sm font-medium transition',
                    isActive
                      ? 'bg-primary/15 text-text-primary ring-1 ring-primary/30'
                      : 'text-text-muted hover:bg-surface-alt hover:text-text-primary',
                  )
                }
              >
                <Icon size={18} />
                <span>{item.label}</span>
                {item.to === '/notifications' && unreadCount > 0 && (
                  <span className="ml-auto rounded-full bg-accent/15 px-2 py-0.5 text-[10px] font-bold text-accent">
                    {unreadCount}
                  </span>
                )}
              </NavLink>
            )
          })}

          <div className="mt-6 rounded-xl border border-border bg-surface-alt/60 p-3">
            <div className="flex items-center gap-2 text-xs font-semibold text-text-secondary">
              <ShieldCheck size={14} className="text-accent" />
              Akses PT
            </div>
            <p className="mt-2 text-xs leading-5 text-text-muted">
              Hanya klien yang terhubung ke akun PT ini yang ditampilkan.
            </p>
          </div>
        </nav>

        <div className="border-t border-border p-4">
          <div className="rounded-xl bg-surface-alt/70 p-3">
            <div className="flex items-center gap-3">
              <div className="flex h-10 w-10 items-center justify-center rounded-full bg-primary/20 text-sm font-bold text-accent">
                {initial}
              </div>
              <div className="min-w-0">
                <p className="truncate text-sm font-semibold">
                  {user?.name ?? 'Personal Trainer'}
                </p>
                <p className="text-xs text-text-muted">Role PT</p>
              </div>
            </div>
            <button
              type="button"
              onClick={logout}
              className="mt-3 flex w-full items-center justify-center gap-2 rounded-lg border border-border px-3 py-2 text-xs font-semibold text-text-secondary transition hover:border-danger/40 hover:bg-danger/10 hover:text-danger"
            >
              <LogOut size={14} />
              Keluar
            </button>
          </div>
        </div>
      </aside>

      <div className="relative lg:pl-72">
        <header className="sticky top-0 z-20 border-b border-border bg-background/80 backdrop-blur-xl">
          <div className="flex h-20 items-center gap-4 px-4 sm:px-6 lg:px-8">
            <button
              type="button"
              className="rounded-lg p-2 text-text-muted transition hover:bg-surface-alt hover:text-text-primary lg:hidden"
              onClick={() => setSidebarOpen(true)}
              aria-label="Buka menu"
            >
              <Menu size={20} />
            </button>

            <div className="min-w-0 flex-1">
              <h1 className="truncate text-lg font-semibold">{page.title}</h1>
              <p className="hidden truncate text-xs text-text-muted sm:block">
                {page.subtitle}
              </p>
            </div>

            <div className="hidden items-center gap-2 rounded-full border border-border bg-surface px-3 py-1.5 text-xs text-text-muted sm:flex">
              <span className="h-2 w-2 rounded-full bg-success" />
              Backend lokal
            </div>
          </div>
        </header>

        <main className="px-4 py-6 sm:px-6 lg:px-8">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
