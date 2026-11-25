import type { Metadata } from 'next'
import { ArrowLeft, ClipboardCheck, Sparkles } from 'lucide-react'
import Link from 'next/link'
import { notFound } from 'next/navigation'
import { PlanViewer } from '@/components/plans/plan-viewer'
import { ReviewActions } from '@/components/plans/review-actions'
import { EmptyState } from '@/components/ui/empty-state'
import { StatusBadge } from '@/components/ui/status-badge'
import { ApiError } from '@/lib/api'
import { formatDateTime, formatWeekRange } from '@/lib/dates'
import { getPlanFromAnalysis } from '@/lib/plan'
import {
  getClient,
  getCurrentAnalysis,
  getExercises,
  getFoods,
} from '@/lib/pt'
import { requireSession } from '@/lib/session'
import type { ClientProfile } from '@/types/api'

export const metadata: Metadata = {
  title: 'Review Rencana',
}

export default async function ReviewPlanPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const clientId = Number(id)

  if (!Number.isInteger(clientId) || clientId < 1) notFound()

  const session = await requireSession()

  let client: ClientProfile
  try {
    client = await getClient(clientId, session.token)
  } catch (error) {
    if (error instanceof ApiError && error.status === 404) notFound()
    throw error
  }

  const analysis = await getCurrentAnalysis(clientId, session.token)
  const plan = analysis ? getPlanFromAnalysis(analysis) : null

  if (!analysis || !plan) {
    return (
      <div className="mx-auto max-w-6xl space-y-6">
        <Link
          href={`/clients/${clientId}`}
          className="inline-flex items-center gap-2 text-sm font-medium text-text-muted transition hover:text-text-primary"
        >
          <ArrowLeft size={16} />
          Kembali ke detail klien
        </Link>

        <section className="panel">
          <EmptyState
            icon={Sparkles}
            title="Belum ada rencana AI"
            description="Kembali ke detail klien untuk membuat rencana mingguan terlebih dahulu."
            action={
              <Link href={`/clients/${clientId}`} className="btn-primary">
                <ClipboardCheck size={16} />
                Buka detail klien
              </Link>
            }
          />
        </section>
      </div>
    )
  }

  const [exercises, foods] = await Promise.all([
    getExercises(session.token),
    getFoods(session.token),
  ])
  const isPending = analysis.status === 'pending'

  return (
    <div className="mx-auto max-w-6xl space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <Link
          href={`/clients/${clientId}`}
          className="inline-flex items-center gap-2 text-sm font-medium text-text-muted transition hover:text-text-primary"
        >
          <ArrowLeft size={16} />
          Kembali ke detail klien
        </Link>

        <StatusBadge status={analysis.status} />
      </div>

      <section className="panel p-6 sm:p-8">
        <div className="flex flex-col gap-5 lg:flex-row lg:items-start lg:justify-between">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.22em] text-accent">
              Review Rencana AI
            </p>
            <h2 className="mt-2 text-2xl font-semibold tracking-tight sm:text-3xl">
              {client.name}
            </h2>
            <div className="mt-2 space-y-1 text-sm text-text-muted">
              <p>Minggu {formatWeekRange(analysis.week_start_date)}</p>
              <p>
                {analysis.reviewed_at
                  ? `Direview ${formatDateTime(analysis.reviewed_at)}`
                  : 'Belum direview'}
              </p>
            </div>
          </div>

          {isPending && (
            <ReviewActions
              plan={plan}
              client={client}
              exercises={exercises}
              foods={foods}
              analysisId={analysis.analysis_id}
              clientId={clientId}
            />
          )}
        </div>

        {isPending && (
          <div className="mt-5 rounded-xl border border-warning/25 bg-warning/10 px-4 py-3 text-sm leading-6 text-warning">
            Rencana belum terlihat oleh klien. Setelah disetujui atau
            di-override, rencana langsung diterapkan ke aplikasi klien.
          </div>
        )}

        {!isPending && (
          <div className="mt-5 rounded-xl border border-success/25 bg-success/10 px-4 py-3 text-sm leading-6 text-success">
            Rencana ini sudah diproses dengan status{' '}
            <strong>{analysis.status}</strong>. Perubahan rencana untuk minggu
            yang sama tidak bisa ditimpa.
          </div>
        )}
      </section>

      <PlanViewer plan={plan} exercises={exercises} foods={foods} />
    </div>
  )
}
