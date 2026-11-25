import type { PaginatedClients } from '@/types/api'

export async function fetchClientsPage(params: {
  page: number
  limit: number
  search?: string
  status?: string
  sort?: string
  order?: string
}) {
  const query = new URLSearchParams({
    page: String(params.page),
    limit: String(params.limit),
    status: params.status ?? 'active',
    sort: params.sort ?? 'name',
    order: params.order ?? 'asc',
  })

  if (params.search) query.set('search', params.search)

  const response = await fetch(`/api/pt/clients?${query.toString()}`)
  const body = await response.json()

  if (!response.ok) {
    throw new Error(body?.message ?? `Permintaan gagal (${response.status}).`)
  }

  return body as PaginatedClients
}
