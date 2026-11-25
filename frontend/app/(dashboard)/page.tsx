import type { Metadata } from 'next'
import { ClientDirectory } from '@/components/clients/client-directory'
import { getClientsPage } from '@/lib/pt'
import { requireSession } from '@/lib/session'

export const metadata: Metadata = {
  title: 'Dashboard',
}

type SearchParams = Promise<Record<string, string | string[] | undefined>>

function first(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] : value
}

export default async function DashboardPage({
  searchParams,
}: {
  searchParams: SearchParams
}) {
  const params = await searchParams
  const session = await requireSession()

  const page = Math.max(1, Number(first(params.page) ?? 1) || 1)
  const limit = Math.min(
    100,
    Math.max(1, Number(first(params.limit) ?? 10) || 10),
  )
  const search = first(params.search) ?? ''
  const status = first(params.status) === 'inactive' ? 'inactive' : 'active'
  const sortValue = first(params.sort) ?? 'name'
  const sort = [
    'client_id',
    'name',
    'weight_current',
    'weight_target',
    'status',
  ].includes(sortValue)
    ? sortValue
    : 'name'
  const order = first(params.order) === 'desc' ? 'desc' : 'asc'

  const initialData = await getClientsPage(session.token, {
    page,
    limit,
    search,
    status,
    sort,
    order,
  })

  return (
    <ClientDirectory
      initialData={initialData}
      initialQuery={{ page, limit, search, status, sort, order }}
      userName={session.user.name}
    />
  )
}
