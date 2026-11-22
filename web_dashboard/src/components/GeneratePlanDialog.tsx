import { CalendarDays, X } from 'lucide-react'
import { useState } from 'react'
import { getNextMonday, parseIsoDate } from '../utils/dates'

export function GeneratePlanDialog({
  clientName,
  isPending,
  onClose,
  onSubmit,
}: {
  clientName: string
  isPending: boolean
  onClose: () => void
  onSubmit: (weekStartDate: string) => void
}) {
  const [weekStartDate, setWeekStartDate] = useState(() => getNextMonday())
  const [error, setError] = useState<string | null>(null)

  function handleSubmit() {
    setError(null)

    if (!weekStartDate) {
      setError('Tanggal minggu wajib dipilih.')
      return
    }

    if (parseIsoDate(weekStartDate).getDay() !== 1) {
      setError('Tanggal harus hari Senin.')
      return
    }

    onSubmit(weekStartDate)
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 p-4 backdrop-blur-sm">
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="generate-plan-title"
        className="w-full max-w-md rounded-2xl border border-border bg-surface p-6 shadow-2xl"
      >
        <div className="flex items-start justify-between gap-4">
          <div className="rounded-xl bg-primary/15 p-3 text-accent">
            <CalendarDays size={22} />
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

        <h2 id="generate-plan-title" className="mt-4 text-xl font-semibold">
          Generate rencana AI
        </h2>
        <p className="mt-2 text-sm leading-6 text-text-muted">
          Buat rencana mingguan untuk <strong>{clientName}</strong>. Rencana
          akan berstatus pending sampai kamu review.
        </p>

        <label className="mt-5 block">
          <span className="mb-2 block text-xs font-semibold uppercase tracking-[0.16em] text-text-muted">
            Minggu dimulai
          </span>
          <input
            type="date"
            className="input"
            value={weekStartDate}
            onChange={(event) => setWeekStartDate(event.target.value)}
          />
        </label>

        {error && (
          <p className="mt-3 rounded-xl border border-danger/30 bg-danger/10 px-3 py-2 text-sm text-danger">
            {error}
          </p>
        )}

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
            onClick={handleSubmit}
            disabled={isPending}
            className="btn-primary"
          >
            {isPending ? 'Membuat rencana...' : 'Generate'}
          </button>
        </div>
      </div>
    </div>
  )
}
