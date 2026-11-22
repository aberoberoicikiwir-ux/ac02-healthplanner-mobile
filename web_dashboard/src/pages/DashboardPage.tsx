import { useQueries, useQuery } from '@tanstack/react-query'
import {
  ArrowRight,
  CalendarDays,
  ClipboardCheck,
  Search,
  Users,
} from 'lucide-react'
import { useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { getClients, getCurrentAnalysis } from '../api/pt'
import { useAuth } from '../auth/auth-context'
import { EmptyState } from '../components/EmptyState'
import { ErrorState } from '../components/ErrorState'
import { LoadingSkeleton } from '../components/LoadingSkeleton'
import { StatusBadge } from '../components/StatusBadge'
import { formatDate, getCurrentWeekStart } from '../utils/dates'
import { getErrorMessage } from '../utils/errors'

export function DashboardPage() {
  const { user } = useAuth()
  const [search, setSearch] = useState('')
  const clientsQuery = useQuery({
    queryKey: ['pt', 'clients'],
    queryFn: getClients,
  })
  const clients = useMemo(() => clientsQuery.data ?? [], [clientsQuery.data])

  const analysisQueries = useQueries({
    queries: clients.map((client) => ({
      queryKey: ['pt', 'analysis', client.client_id],
      queryFn: () => getCurrentAnalysis(client.client_id),
      retry: false,
      staleTime: 30_000,
    })),
  })

  const analysisByClient = useMemo(() => {
    const map = new Map<number, (typeof analysisQueries)[number]['data']>()
    clients.forEach((client, index) => {
      map.set(client.client_id, analysisQueries[index]?.data ?? null)
    })
    return map
  }, [analysisQueries, clients])

  const currentWeekStart = getCurrentWeekStart()
  const pendingClients = clients.filter(
    (client) => analysisByClient.get(client.client_id)?.status === 'pending',
  )
  const currentWeekPlans = clients.filter(
    (client) =>
      analysisByClient.get(client.client_id)?.week_start_date ===
      currentWeekStart,
  )

  const filteredClients = clients.filter((client) => {
    const query = search.trim().toLowerCase()
    if (!query) return true
    return (
      client.name.toLowerCase().includes(query) ||
      client.email.toLowerCase().includes(query)
    )
  })

  if (clientsQuery.isLoading) {
    return (
      <div className="mx-auto max-w-6xl space-y-6">
        <LoadingSkeleton rows={1} />
        <div className="grid gap-4 sm:grid-cols-3">
          <LoadingSkeleton rows={1} />
          <LoadingSkeleton rows={1} />
          <LoadingSkeleton rows={1} />
        </div>
        <LoadingSkeleton rows={4} />
      </div>
    )
  }

  if (clientsQuery.isError) {
    return (
      <div className="mx-auto max-w-6xl">
        <ErrorState
          message={getErrorMessage(clientsQuery.error)}
          onRetry={() => void clientsQuery.refetch()}
        />
      </div>
    )
  }

  return (
    <div className="mx-auto max-w-6xl space-y-6">
      <section className="panel p-6 sm:p-8">
        <div className="flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.22em] text-accent">
              Dashboard PT
            </p>
            <h2 className="mt-2 text-2xl font-semibold tracking-tight sm:text-3xl">
              Selamat datang, {user?.name ?? 'Personal Trainer'}.
            </h2>
            <p className="mt-3 max-w-2xl text-sm leading-6 text-text-muted">
              Pantau klien aktif, lihat progres, dan review rencana mingguan
              sebelum diterapkan ke aplikasi klien.
            </p>
          </div>

          <label className="relative block w-full max-w-sm">
            <Search
              size={17}
              className="pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 text-text-muted"
            />
            <input
              className="input pl-11"
              type="search"
              value={search}
              onChange={(event) => setSearch(event.target.value)}
              placeholder="Cari nama atau email klien..."
            />
          </label>
        </div>
      </section>

      <section className="grid gap-4 sm:grid-cols-3">
        <div className="panel p-5">
          <div className="flex items-start justify-between gap-4">
            <div>
              <p className="text-sm text-text-muted">Klien aktif</p>
              <p className="mt-2 text-3xl font-semibold">{clients.length}</p>
            </div>
            <div className="rounded-xl bg-primary/15 p-3 text-accent">
              <Users size={20} />
            </div>
          </div>
        </div>
        <div className="panel p-5">
          <div className="flex items-start justify-between gap-4">
            <div>
              <p className="text-sm text-text-muted">Menunggu review</p>
              <p className="mt-2 text-3xl font-semibold">
                {pendingClients.length}
              </p>
            </div>
            <div className="rounded-xl bg-warning/10 p-3 text-warning">
              <ClipboardCheck size={20} />
            </div>
          </div>
        </div>
        <div className="panel p-5">
          <div className="flex items-start justify-between gap-4">
            <div>
              <p className="text-sm text-text-muted">Rencana minggu ini</p>
              <p className="mt-2 text-3xl font-semibold">
                {currentWeekPlans.length}
              </p>
            </div>
            <div className="rounded-xl bg-success/10 p-3 text-success">
              <CalendarDays size={20} />
            </div>
          </div>
        </div>
      </section>

      {pendingClients.length > 0 && (
        <section className="panel p-5 sm:p-6">
          <div className="flex items-center justify-between gap-3">
            <div>
              <h3 className="text-lg font-semibold">Perlu review</h3>
              <p className="text-xs text-text-muted">
                Rencana AI sudah siap dan menunggu keputusanmu.
              </p>
            </div>
            <span className="rounded-full bg-warning/10 px-3 py-1 text-xs font-semibold text-warning">
              {pendingClients.length} pending
            </span>
          </div>

          <div className="mt-4 grid gap-3 md:grid-cols-2 xl:grid-cols-3">
            {pendingClients.map((client) => {
              const analysis = analysisByClient.get(client.client_id)

              return (
                <Link
                  key={client.client_id}
                  to={`/clients/${client.client_id}/review`}
                  className="group rounded-xl border border-warning/20 bg-warning/5 p-4 transition hover:border-warning/40 hover:bg-warning/10"
                >
                  <div className="flex items-start justify-between gap-3">
                    <div>
                      <p className="font-semibold">{client.name}</p>
                      <p className="mt-1 text-xs text-text-muted">
                        Minggu {formatDate(analysis?.week_start_date)}
                      </p>
                    </div>
                    <ArrowRight
                      size={17}
                      className="text-warning transition group-hover:translate-x-0.5"
                    />
                  </div>
                  <p className="mt-3 text-xs text-warning">
                    Buka review rencana AI
                  </p>
                </Link>
              )
            })}
          </div>
        </section>
      )}

      <section className="panel overflow-hidden">
        <div className="flex items-center justify-between gap-3 border-b border-border px-5 py-4">
          <div>
            <h3 className="text-lg font-semibold">Klien aktif</h3>
            <p className="text-xs text-text-muted">
              {filteredClients.length} dari {clients.length} klien
            </p>
          </div>
        </div>

        {clients.length === 0 ? (
          <EmptyState
            icon={Users}
            title="Belum ada klien aktif"
            description="Klien akan muncul setelah akun klien terhubung ke PT ini."
          />
        ) : filteredClients.length === 0 ? (
          <EmptyState
            icon={Search}
            title="Klien tidak ditemukan"
            description="Coba kata kunci nama atau email yang lain."
          />
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-[760px] w-full text-left text-sm">
              <thead className="border-b border-border bg-surface-alt/40 text-xs uppercase tracking-[0.14em] text-text-muted">
                <tr>
                  <th className="px-5 py-3 font-semibold">Klien</th>
                  <th className="px-5 py-3 font-semibold">Berat</th>
                  <th className="px-5 py-3 font-semibold">Target</th>
                  <th className="px-5 py-3 font-semibold">Rencana</th>
                  <th className="px-5 py-3 font-semibold" />
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {filteredClients.map((client) => {
                  const analysis = analysisByClient.get(client.client_id)

                  return (
                    <tr
                      key={client.client_id}
                      className="transition hover:bg-surface-alt/30"
                    >
                      <td className="px-5 py-4">
                        <Link
                          to={`/clients/${client.client_id}`}
                          className="font-semibold text-text-primary hover:text-accent"
                        >
                          {client.name}
                        </Link>
                        <p className="mt-0.5 text-xs text-text-muted">
                          {client.email}
                        </p>
                      </td>
                      <td className="px-5 py-4 text-text-secondary">
                        {client.weight_current} kg
                      </td>
                      <td className="px-5 py-4 text-text-secondary">
                        {client.weight_target} kg
                      </td>
                      <td className="px-5 py-4">
                        <StatusBadge status={analysis?.status ?? 'none'} />
                      </td>
                      <td className="px-5 py-4 text-right">
                        <Link
                          to={`/clients/${client.client_id}`}
                          className="inline-flex items-center gap-1.5 text-xs font-semibold text-accent hover:text-accent/80"
                        >
                          Detail
                          <ArrowRight size={14} />
                        </Link>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        )}
      </section>
    </div>
  )
}
