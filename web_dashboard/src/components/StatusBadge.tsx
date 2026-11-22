import type { AnalysisStatus } from '../types/api'

const styles: Record<string, string> = {
  pending: 'border-warning/25 bg-warning/10 text-warning',
  approved: 'border-success/25 bg-success/10 text-success',
  overridden: 'border-primary/25 bg-primary/10 text-accent',
  none: 'border-border bg-surface-alt text-text-muted',
  active: 'border-success/25 bg-success/10 text-success',
  inactive: 'border-border bg-surface-alt text-text-muted',
}

const labels: Record<string, string> = {
  pending: 'Menunggu review',
  approved: 'Disetujui',
  overridden: 'Di-override',
  none: 'Belum ada rencana',
  active: 'Aktif',
  inactive: 'Nonaktif',
}

export function StatusBadge({
  status,
  className = '',
}: {
  status: AnalysisStatus | string | null | undefined
  className?: string
}) {
  const key = status ?? 'none'

  return (
    <span
      className={`inline-flex items-center rounded-full border px-2.5 py-1 text-xs font-semibold ${
        styles[key] ?? styles.none
      } ${className}`}
    >
      {labels[key] ?? status}
    </span>
  )
}
