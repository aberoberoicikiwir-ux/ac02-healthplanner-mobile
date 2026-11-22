import { AlertTriangle, X } from 'lucide-react'
import type { ReactNode } from 'react'

export function ConfirmDialog({
  title,
  description,
  confirmLabel,
  isPending,
  onConfirm,
  onClose,
  children,
}: {
  title: string
  description: string
  confirmLabel: string
  isPending?: boolean
  onConfirm: () => void
  onClose: () => void
  children?: ReactNode
}) {
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 p-4 backdrop-blur-sm">
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="confirm-dialog-title"
        className="w-full max-w-md rounded-2xl border border-border bg-surface p-6 shadow-2xl"
      >
        <div className="flex items-start justify-between gap-4">
          <div className="rounded-xl bg-warning/10 p-3 text-warning">
            <AlertTriangle size={22} />
          </div>
          <button
            type="button"
            onClick={onClose}
            className="rounded-lg p-1.5 text-text-muted transition hover:bg-surface-alt hover:text-text-primary"
            aria-label="Tutup"
          >
            <X size={18} />
          </button>
        </div>

        <h2 id="confirm-dialog-title" className="mt-4 text-xl font-semibold">
          {title}
        </h2>
        <p className="mt-2 text-sm leading-6 text-text-muted">{description}</p>
        {children && <div className="mt-4">{children}</div>}

        <div className="mt-6 flex justify-end gap-3">
          <button
            type="button"
            onClick={onClose}
            className="rounded-xl border border-border px-4 py-2.5 text-sm font-semibold text-text-secondary transition hover:bg-surface-alt"
          >
            Batal
          </button>
          <button
            type="button"
            onClick={onConfirm}
            disabled={isPending}
            className="btn-primary"
          >
            {isPending ? 'Memproses...' : confirmLabel}
          </button>
        </div>
      </div>
    </div>
  )
}
