import { Bell, Inbox } from 'lucide-react'

export function NotificationsPage() {
  return (
    <div className="mx-auto max-w-4xl space-y-6">
      <section className="panel p-6 sm:p-8">
        <div className="flex items-start gap-4">
          <div className="rounded-2xl bg-primary/15 p-3 text-accent">
            <Bell size={24} />
          </div>
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.22em] text-accent">
              Notifikasi
            </p>
            <h2 className="mt-2 text-2xl font-semibold tracking-tight">
              Belum ada notifikasi untuk ditampilkan.
            </h2>
            <p className="mt-3 max-w-2xl text-sm leading-6 text-text-muted">
              Halaman ini sudah disiapkan. Pada fase 5, data akan diambil dari{' '}
              <code className="rounded bg-surface-alt px-1.5 py-0.5 text-xs text-text-secondary">
                GET /api/users/me/notifications
              </code>{' '}
              dan bisa ditandai sudah dibaca.
            </p>
          </div>
        </div>
      </section>

      <section className="panel flex flex-col items-center justify-center px-6 py-14 text-center">
        <div className="rounded-2xl bg-surface-alt p-4 text-text-muted">
          <Inbox size={28} />
        </div>
        <h3 className="mt-4 text-lg font-semibold">Kotak masuk masih kosong</h3>
        <p className="mt-2 max-w-md text-sm leading-6 text-text-muted">
          Notifikasi rencana AI dan pengingat review akan muncul di sini setelah
          integrasi fase berikutnya.
        </p>
      </section>
    </div>
  )
}
