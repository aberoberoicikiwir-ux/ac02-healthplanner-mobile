import type { Metadata } from 'next'
import { Bell, CheckCheck, Inbox, Info, Sparkles } from 'lucide-react'
import { SubmitButton } from '@/components/ui/submit-button'
import { EmptyState } from '@/components/ui/empty-state'
import { formatDateTime } from '@/lib/dates'
import { getNotifications } from '@/lib/pt'
import { requireSession } from '@/lib/session'
import type { NotificationItem } from '@/types/api'
import { markAllReadAction, markReadAction } from './actions'

export const metadata: Metadata = {
  title: 'Notifikasi',
}

function notificationIcon(type: NotificationItem['type']) {
  if (type === 'ai_insight') return Sparkles
  if (type === 'reminder') return Bell
  return Info
}

export default async function NotificationsPage() {
  const session = await requireSession()
  const notifications = await getNotifications(session.token)
  const unread = notifications.filter((item) => !item.is_read)

  return (
    <div className="mx-auto max-w-4xl space-y-6">
      <section className="panel p-6 sm:p-8">
        <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.22em] text-accent">
              Notifikasi
            </p>
            <h2 className="mt-2 text-2xl font-semibold tracking-tight">
              Kotak masuk PT
            </h2>
            <p className="mt-2 text-sm text-text-muted">
              {notifications.length} notifikasi · {unread.length} belum dibaca
            </p>
          </div>

          {unread.length > 0 && (
            <form action={markAllReadAction}>
              <SubmitButton
                pendingText="Menandai..."
                className="inline-flex items-center gap-2 rounded-xl border border-border px-4 py-2.5 text-sm font-semibold text-text-secondary transition hover:bg-surface-alt disabled:opacity-60"
              >
                <CheckCheck size={16} />
                Tandai semua dibaca
              </SubmitButton>
            </form>
          )}
        </div>
      </section>

      {notifications.length === 0 ? (
        <section className="panel">
          <EmptyState
            icon={Inbox}
            title="Belum ada notifikasi"
            description="Notifikasi rencana AI dan pengingat review akan muncul di sini."
          />
        </section>
      ) : (
        <section className="space-y-3">
          {notifications.map((item) => {
            const Icon = notificationIcon(item.type)

            return (
              <article
                key={item.notification_id}
                className={`panel p-5 ${
                  item.is_read ? '' : 'border-accent/20 bg-accent/[0.03]'
                }`}
              >
                <div className="flex items-start gap-4">
                  <div
                    className={`rounded-xl p-2.5 ${
                      item.type === 'ai_insight'
                        ? 'bg-primary/15 text-accent'
                        : item.type === 'reminder'
                          ? 'bg-warning/10 text-warning'
                          : 'bg-surface-alt text-text-muted'
                    }`}
                  >
                    <Icon size={18} />
                  </div>

                  <div className="min-w-0 flex-1">
                    <div className="flex flex-wrap items-start justify-between gap-2">
                      <div>
                        <h3 className="font-semibold">{item.title}</h3>
                        <p className="mt-1 text-xs text-text-muted">
                          {formatDateTime(item.created_at)}
                        </p>
                      </div>
                      {!item.is_read && (
                        <span className="rounded-full bg-accent/10 px-2.5 py-1 text-[10px] font-semibold uppercase tracking-[0.14em] text-accent">
                          Baru
                        </span>
                      )}
                    </div>

                    <p className="mt-3 whitespace-pre-line text-sm leading-6 text-text-secondary">
                      {item.message}
                    </p>

                    {!item.is_read && (
                      <form action={markReadAction} className="mt-3">
                        <input
                          type="hidden"
                          name="notificationId"
                          value={item.notification_id}
                        />
                        <SubmitButton
                          pendingText="Menandai..."
                          className="inline-flex items-center gap-1.5 text-xs font-semibold text-accent transition hover:text-accent/80 disabled:opacity-60"
                        >
                          <CheckCheck size={14} />
                          Tandai dibaca
                        </SubmitButton>
                      </form>
                    )}
                  </div>
                </div>
              </article>
            )
          })}
        </section>
      )}
    </div>
  )
}
