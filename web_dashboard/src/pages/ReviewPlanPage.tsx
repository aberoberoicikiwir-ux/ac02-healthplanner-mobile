import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import {
  ArrowLeft,
  CheckCircle2,
  ClipboardCheck,
  PenLine,
  Sparkles,
} from 'lucide-react'
import { useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { toast } from 'sonner'
import { getExercises, getFoods } from '../api/masterData'
import {
  approveAnalysis,
  getClient,
  getCurrentAnalysis,
  overrideAnalysis,
} from '../api/pt'
import { ConfirmDialog } from '../components/ConfirmDialog'
import { EmptyState } from '../components/EmptyState'
import { ErrorState } from '../components/ErrorState'
import { LoadingSkeleton } from '../components/LoadingSkeleton'
import { PlanEditor } from '../components/PlanEditor'
import { PlanViewer } from '../components/PlanViewer'
import { StatusBadge } from '../components/StatusBadge'
import type { PlanOutput } from '../types/api'
import { formatDateTime, formatWeekRange } from '../utils/dates'
import { getErrorMessage } from '../utils/errors'
import { getPlanFromAnalysis } from '../utils/plan'

export function ReviewPlanPage() {
  const params = useParams<{ clientId: string }>()
  const clientId = Number(params.clientId)
  const queryClient = useQueryClient()
  const [showApprove, setShowApprove] = useState(false)
  const [showOverride, setShowOverride] = useState(false)
  const enabled = Number.isInteger(clientId) && clientId > 0

  const clientQuery = useQuery({
    queryKey: ['pt', 'client', clientId],
    queryFn: () => getClient(clientId),
    enabled,
  })
  const analysisQuery = useQuery({
    queryKey: ['pt', 'analysis', clientId],
    queryFn: () => getCurrentAnalysis(clientId),
    enabled,
  })
  const exercisesQuery = useQuery({
    queryKey: ['master', 'exercises'],
    queryFn: getExercises,
    staleTime: 5 * 60_000,
  })
  const foodsQuery = useQuery({
    queryKey: ['master', 'foods'],
    queryFn: getFoods,
    staleTime: 5 * 60_000,
  })

  const analysis = analysisQuery.data ?? null
  const plan = analysis ? getPlanFromAnalysis(analysis) : null
  const client = clientQuery.data
  const exercises = exercisesQuery.data ?? []
  const foods = foodsQuery.data ?? []

  const invalidateReviewData = () => {
    void queryClient.invalidateQueries({
      queryKey: ['pt', 'analysis', clientId],
    })
    void queryClient.invalidateQueries({ queryKey: ['pt', 'clients'] })
    void queryClient.invalidateQueries({ queryKey: ['notifications'] })
  }

  const approveMutation = useMutation({
    mutationFn: async () => {
      if (!analysis) throw new Error('Rencana belum tersedia.')
      return approveAnalysis(analysis.analysis_id)
    },
    onSuccess: () => {
      toast.success('Rencana disetujui dan diterapkan ke klien.')
      setShowApprove(false)
      invalidateReviewData()
    },
    onError: (error) => toast.error(getErrorMessage(error)),
  })

  const overrideMutation = useMutation({
    mutationFn: async (finalOutput: PlanOutput) => {
      if (!analysis) throw new Error('Rencana belum tersedia.')
      return overrideAnalysis(analysis.analysis_id, finalOutput)
    },
    onSuccess: () => {
      toast.success('Rencana berhasil di-override dan diterapkan ke klien.')
      setShowOverride(false)
      invalidateReviewData()
    },
    onError: (error) => toast.error(getErrorMessage(error)),
  })

  if (!enabled) {
    return (
      <div className="mx-auto max-w-6xl">
        <ErrorState message="ID klien tidak valid." />
      </div>
    )
  }

  if (clientQuery.isLoading || analysisQuery.isLoading) {
    return (
      <div className="mx-auto max-w-6xl space-y-6">
        <LoadingSkeleton rows={1} />
        <LoadingSkeleton rows={3} />
      </div>
    )
  }

  if (clientQuery.isError) {
    return (
      <div className="mx-auto max-w-6xl">
        <ErrorState
          message={getErrorMessage(clientQuery.error)}
          onRetry={() => void clientQuery.refetch()}
        />
      </div>
    )
  }

  if (analysisQuery.isError) {
    return (
      <div className="mx-auto max-w-6xl">
        <ErrorState
          message={getErrorMessage(analysisQuery.error)}
          onRetry={() => void analysisQuery.refetch()}
        />
      </div>
    )
  }

  if (!client) {
    return (
      <div className="mx-auto max-w-6xl">
        <ErrorState message="Klien tidak ditemukan atau bukan bimbinganmu." />
      </div>
    )
  }

  const isPending = analysis?.status === 'pending'
  const masterDataLoading = exercisesQuery.isLoading || foodsQuery.isLoading

  return (
    <div className="mx-auto max-w-6xl space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <Link
          to={`/clients/${clientId}`}
          className="inline-flex items-center gap-2 text-sm font-medium text-text-muted transition hover:text-text-primary"
        >
          <ArrowLeft size={16} />
          Kembali ke detail klien
        </Link>

        {analysis && <StatusBadge status={analysis.status} />}
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
            {analysis ? (
              <div className="mt-2 space-y-1 text-sm text-text-muted">
                <p>Minggu {formatWeekRange(analysis.week_start_date)}</p>
                <p>
                  {analysis.reviewed_at
                    ? `Direview ${formatDateTime(analysis.reviewed_at)}`
                    : 'Belum direview'}
                </p>
              </div>
            ) : (
              <p className="mt-2 text-sm text-text-muted">
                Belum ada rencana AI untuk klien ini.
              </p>
            )}
          </div>

          {isPending && (
            <div className="flex flex-wrap gap-3">
              <button
                type="button"
                onClick={() => setShowOverride(true)}
                disabled={masterDataLoading || !plan}
                className="inline-flex items-center gap-2 rounded-xl border border-border px-4 py-2.5 text-sm font-semibold text-text-secondary transition hover:bg-surface-alt disabled:cursor-not-allowed disabled:opacity-60"
              >
                <PenLine size={16} />
                Override
              </button>
              <button
                type="button"
                onClick={() => setShowApprove(true)}
                disabled={!plan}
                className="btn-primary"
              >
                <CheckCircle2 size={16} />
                Setujui Rencana
              </button>
            </div>
          )}
        </div>

        {isPending && (
          <div className="mt-5 rounded-xl border border-warning/25 bg-warning/10 px-4 py-3 text-sm leading-6 text-warning">
            Rencana belum terlihat oleh klien. Setelah disetujui atau
            di-override, rencana langsung diterapkan ke aplikasi klien.
          </div>
        )}

        {analysis && !isPending && (
          <div className="mt-5 rounded-xl border border-success/25 bg-success/10 px-4 py-3 text-sm leading-6 text-success">
            Rencana ini sudah diproses dengan status{' '}
            <strong>{analysis.status}</strong>. Perubahan rencana untuk minggu
            yang sama tidak bisa ditimpa.
          </div>
        )}
      </section>

      {!analysis || !plan ? (
        <section className="panel">
          <EmptyState
            icon={Sparkles}
            title="Belum ada rencana AI"
            description="Kembali ke detail klien untuk membuat rencana mingguan terlebih dahulu."
            action={
              <Link to={`/clients/${clientId}`} className="btn-primary">
                <ClipboardCheck size={16} />
                Buka detail klien
              </Link>
            }
          />
        </section>
      ) : (
        <PlanViewer plan={plan} exercises={exercises} foods={foods} />
      )}

      {showApprove && (
        <ConfirmDialog
          title="Setujui rencana AI?"
          description="Rencana akan diterapkan ke workout plan, meal plan, dan target klien. Setelah disetujui, rencana untuk minggu ini tidak bisa ditinjau ulang."
          confirmLabel="Ya, setujui"
          isPending={approveMutation.isPending}
          onConfirm={() => approveMutation.mutate()}
          onClose={() => setShowApprove(false)}
        />
      )}

      {showOverride && plan && (
        <PlanEditor
          key={analysis?.analysis_id ?? 'override'}
          plan={plan}
          client={client}
          exercises={exercises}
          foods={foods}
          isSubmitting={overrideMutation.isPending}
          onCancel={() => setShowOverride(false)}
          onSubmit={async (draft) => {
            try {
              await overrideMutation.mutateAsync(draft)
            } catch {
              // Error toast sudah ditangani oleh onError mutation.
            }
          }}
        />
      )}
    </div>
  )
}
