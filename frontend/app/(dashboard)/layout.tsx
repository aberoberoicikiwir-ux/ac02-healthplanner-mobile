import type { ReactNode } from 'react'
import { AppShell } from '@/components/layout/app-shell'
import { getNotifications } from '@/lib/pt'
import { requireSession } from '@/lib/session'

export default async function DashboardLayout({
  children,
}: {
  children: ReactNode
}) {
  const session = await requireSession()
  let unreadCount = 0

  try {
    const notifications = await getNotifications(session.token)
    unreadCount = notifications.filter((item) => !item.is_read).length
  } catch {
    unreadCount = 0
  }

  return (
    <AppShell user={session.user} unreadCount={unreadCount}>
      {children}
    </AppShell>
  )
}
