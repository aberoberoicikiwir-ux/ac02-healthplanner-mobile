'use client'

import {
  keepPreviousData,
  useQuery,
  useQueryClient,
} from '@tanstack/react-query'
import {
  ArrowRight,
  ChevronLeft,
  ChevronRight,
  Search,
  SlidersHorizontal,
  Users,
} from 'lucide-react'
import Link from 'next/link'
import { usePathname, useRouter, useSearchParams } from 'next/navigation'
import { useCallback, useEffect, useMemo, useState } from 'react'
import { EmptyState } from '@/components/ui/empty-state'
import { ErrorState } from '@/components/ui/error-state'
import { LoadingSkeleton } from '@/components/ui/loading-skeleton'
import { StatusBadge } from '@/components/ui/status-badge'
import { fetchClientsPage } from '@/lib/client-api'
import type { PaginatedClients } from '@/types/api'

interface ClientQuery {
  page: number
  limit: number
  search: string
  status: string
  sort: string
  order: string
}

function queryKey(query: ClientQuery) {
  return [
    'clients',
    query.page,
    query.limit,
    query.search,
    query.status,
    query.sort,
    query.order,
  ] as const
}

export function ClientDirectory({
  initialData,
  initialQuery,
  userName,
}: {
  initialData: PaginatedClients
  initialQuery: ClientQuery
  userName: string
}) {
  const router = useRouter()
  const pathname = usePathname()
  const searchParams = useSearchParams()
  const queryClient = useQueryClient()

  const query: ClientQuery = useMemo(
    () => ({
      page: Number(searchParams.get('page') ?? initialQuery.page) || 1,
      limit: Number(searchParams.get('limit') ?? initialQuery.limit) || 10,
      search: searchParams.get('search') ?? initialQuery.search,
      status: searchParams.get('status') ?? initialQuery.status,
      sort: searchParams.get('sort') ?? initialQuery.sort,
      order: searchParams.get('order') ?? initialQuery.order,
    }),
    [initialQuery, searchParams],
  )

  const [searchInput, setSearchInput] = useState(query.search)

  const setQuery = useCallback(
    (updates: Record<string, string | number | undefined>) => {
      const params = new URLSearchParams(searchParams.toString())

      for (const [key, value] of Object.entries(updates)) {
        if (value === undefined || value === '') {
          params.delete(key)
        } else {
          params.set(key, String(value))
        }
      }

      router.replace(`${pathname}?${params.toString()}`, { scroll: false })
    },
    [pathname, router, searchParams],
  )

  useEffect(() => {
    const timeout = setTimeout(() => {
      if (searchInput !== query.search) {
        setQuery({ search: searchInput || undefined, page: 1 })
      }
    }, 400)

    return () => clearTimeout(timeout)
  }, [query.search, searchInput, setQuery])

  const isInitialQuery =
    query.page === initialQuery.page &&
    query.limit === initialQuery.limit &&
    query.search === initialQuery.search &&
    query.status === initialQuery.status &&
    query.sort === initialQuery.sort &&
    query.order === initialQuery.order

  const clientsQuery = useQuery({
    queryKey: queryKey(query),
    queryFn: () => fetchClientsPage(query),
    placeholderData: keepPreviousData,
    initialData: isInitialQuery ? initialData : undefined,
  })

  const data = clientsQuery.data ?? initialData

  useEffect(() => {
    if (data.meta.page < data.meta.total_pages) {
      const nextQuery = { ...query, page: query.page + 1 }
      void queryClient.prefetchQuery({
        queryKey: queryKey(nextQuery),
        queryFn: () => fetchClientsPage(nextQuery),
      })
    }
  }, [
    data.meta.page,
    data.meta.total_pages,
    query,
    queryClient,
  ])

  if (clientsQuery.isPending && !clientsQuery.data) {
    return (
      <div className="mx-auto max-w-6xl space-y-6">
        <LoadingSkeleton rows={1} />
        <LoadingSkeleton rows={4} />
      </div>
    )
  }

  if (clientsQuery.isError) {
    return (
      <div className="mx-auto max-w-6xl">
        <ErrorState
          message={
            clientsQuery.error instanceof Error
              ? clientsQuery.error.message
              : 'Gagal memuat daftar klien.'
          }
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
              Selamat datang, {userName}.
            </h2>
            <p className="mt-3 max-w-2xl text-sm leading-6 text-text-muted">
              Pantau klien aktif, cari berdasarkan nama/email, dan buka detail
              progres atau review rencana.
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
              value={searchInput}
              onChange={(event) => setSearchInput(event.target.value)}
              placeholder="Cari nama atau email klien..."
            />
          </label>
        </div>

        <div className="mt-5 flex flex-wrap items-center gap-3">
          <label className="flex items-center gap-2 text-xs text-text-muted">
            <SlidersHorizontal size={14} />
            Status
            <select
              className="input w-auto px-3 py-2"
              value={query.status}
              onChange={(event) =>
                setQuery({ status: event.target.value, page: 1 })
              }
            >
              <option value="active">Aktif</option>
              <option value="inactive">Nonaktif</option>
            </select>
          </label>

          <label className="flex items-center gap-2 text-xs text-text-muted">
            Urutkan
            <select
              className="input w-auto px-3 py-2"
              value={`${query.sort}:${query.order}`}
              onChange={(event) => {
                const [sort, order] = event.target.value.split(':')
                setQuery({ sort, order, page: 1 })
              }}
            >
              <option value="name:asc">Nama A–Z</option>
              <option value="name:desc">Nama Z–A</option>
              <option value="weight_current:asc">Berat terendah</option>
              <option value="weight_current:desc">Berat tertinggi</option>
              <option value="client_id:desc">Terbaru</option>
            </select>
          </label>
        </div>
      </section>

      <section className="grid gap-4 sm:grid-cols-3">
        <div className="panel p-5">
          <p className="text-sm text-text-muted">Total klien</p>
          <p className="mt-2 text-3xl font-semibold">{data.meta.total}</p>
        </div>
        <div className="panel p-5">
          <p className="text-sm text-text-muted">Halaman</p>
          <p className="mt-2 text-3xl font-semibold">
            {data.meta.page} / {data.meta.total_pages || 1}
          </p>
        </div>
        <div className="panel p-5">
          <p className="text-sm text-text-muted">Per halaman</p>
          <p className="mt-2 text-3xl font-semibold">{data.meta.limit}</p>
        </div>
      </section>

      <section className="panel overflow-hidden">
        <div className="flex items-center justify-between gap-3 border-b border-border px-5 py-4">
          <div>
            <h3 className="text-lg font-semibold">Klien aktif</h3>
            <p className="text-xs text-text-muted">
              {data.data.length} dari {data.meta.total} klien
            </p>
          </div>
          {clientsQuery.isFetching && (
            <span className="text-xs text-text-muted">Memuat...</span>
          )}
        </div>

        {data.data.length === 0 ? (
          <EmptyState
            icon={Users}
            title="Klien tidak ditemukan"
            description="Coba kata kunci, status, atau urutan yang lain."
          />
        ) : (
          <div className="overflow-x-auto">
            <table
              className="w-full text-left text-sm"
              style={{ minWidth: '760px' }}
            >
              <thead className="border-b border-border bg-surface-alt/40 text-xs uppercase tracking-[0.14em] text-text-muted">
                <tr>
                  <th className="px-5 py-3 font-semibold">Klien</th>
                  <th className="px-5 py-3 font-semibold">Berat</th>
                  <th className="px-5 py-3 font-semibold">Target</th>
                  <th className="px-5 py-3 font-semibold">Status</th>
                  <th className="px-5 py-3 font-semibold" />
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {data.data.map((client) => (
                  <tr
                    key={client.client_id}
                    className="transition hover:bg-surface-alt/30"
                  >
                    <td className="px-5 py-4">
                      <Link
                        href={`/clients/${client.client_id}`}
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
                      <StatusBadge status={client.status} />
                    </td>
                    <td className="px-5 py-4 text-right">
                      <Link
                        href={`/clients/${client.client_id}`}
                        className="inline-flex items-center gap-1.5 text-xs font-semibold text-accent hover:text-accent/80"
                      >
                        Detail
                        <ArrowRight size={14} />
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        <div className="flex flex-wrap items-center justify-between gap-3 border-t border-border px-5 py-4">
          <p className="text-xs text-text-muted">
            Halaman {data.meta.page} dari {data.meta.total_pages || 1}
          </p>
          <div className="flex gap-2">
            <button
              type="button"
              disabled={query.page <= 1}
              onClick={() => setQuery({ page: query.page - 1 })}
              className="inline-flex items-center gap-1.5 rounded-lg border border-border px-3 py-2 text-xs font-semibold text-text-secondary transition hover:bg-surface-alt disabled:cursor-not-allowed disabled:opacity-40"
            >
              <ChevronLeft size={14} />
              Sebelumnya
            </button>
            <button
              type="button"
              disabled={query.page >= (data.meta.total_pages || 1)}
              onClick={() => setQuery({ page: query.page + 1 })}
              className="inline-flex items-center gap-1.5 rounded-lg border border-border px-3 py-2 text-xs font-semibold text-text-secondary transition hover:bg-surface-alt disabled:cursor-not-allowed disabled:opacity-40"
            >
              Berikutnya
              <ChevronRight size={14} />
            </button>
          </div>
        </div>
      </section>
    </div>
  )
}
