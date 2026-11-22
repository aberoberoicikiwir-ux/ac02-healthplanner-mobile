import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import {
  ArrowLeft,
  CalendarDays,
  ClipboardCheck,
  Dumbbell,
  RefreshCw,
  Sparkles,
  Target,
  Utensils,
} from 'lucide-react'
import { useMemo, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { toast } from 'sonner'
import {
  generatePlan,
  getClient,
  getClientProgress,
  getCurrentAnalysis,
} from '../api/pt'
import { EmptyState } from '../components/EmptyState'
import { ErrorState } from '../components/ErrorState'
import { GeneratePlanDialog } from '../components/GeneratePlanDialog'
import { LoadingSkeleton } from '../components/LoadingSkeleton'
import { ProgressCharts } from '../components/ProgressCharts'
import { StatusBadge } from '../components/StatusBadge'
import type { ClientProfile } from '../types/api'
import {
  formatDate,
  formatDateTime,
  formatWeekRange,
  getDateRange,
} from '../utils/dates'
import { getErrorMessage } from '../utils/errors'
import { getPlanFromAnalysis } from '../utils/plan'

function InfoRow({
  label,
  value,
}: {
  label: string
  value: string | number | null | undefined
}) {
  return (
    <div className="flex items-start justify-between gap-4 border-b border-border py-2.5 last:border-0">
      <span className="text-sm text-text-muted">{label}</span>
      <span className="text-right text-sm font-medium">{value ?? '—'}</span>
    </div>
  )
}

function genderLabel(gender: ClientProfile['gender']) {
  if (gender === 'male') return 'Laki-laki'
  if (gender === 'female') return 'Perempuan'
  return '—'
}

export function ClientDetailPage() {
  const params = useParams<{ clientId: string }>()
  const clientId = Number(params.clientId)
  const queryClient = useQueryClient()
  const [rangeDays, setRangeDays] = useState(30)
  const [showGenerate, setShowGenerate] = useState(false)
  const { from, to } = useMemo(() => getDateRange(rangeDays), [rangeDays])
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
  const progressQuery = useQuery({
    queryKey: ['pt', 'progress', clientId, from, to],
    queryFn: () => getClientProgress(clientId, from, to),
    enabled,
  })

  const generateMutation = useMutation({
    mutationFn: (weekStartDate: string) => generatePlan(clientId, weekStartDate),
    onSuccess: () => {
      toast.success('Rencana AI dibuat dan menunggu review.')
      setShowGenerate(false)
      void queryClient.invalidateQueries({
        queryKey: ['pt', 'analysis', clientId],
      })
      void queryClient.invalidateQueries({ queryKey: ['pt', 'clients'] })
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

  if (clientQuery.isLoading) {
    return (
      <div className="mx-auto max-w-6xl space-y-6">
        <LoadingSkeleton rows={1} />
        <div className="grid gap-4 lg:grid-cols-2">
          <LoadingSkeleton rows={1} />
          <LoadingSkeleton rows={1} />
        </div>
        <LoadingSkeleton rows={2} />
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

  const client = clientQuery.data
  if (!client) {
    return (
      <div className="mx-auto max-w-6xl">
        <ErrorState message="Klien tidak ditemukan atau bukan bimbinganmu." />
      </div>
    )
  }

  const analysis = analysisQuery.data ?? null
  const plan = analysis ? getPlanFromAnalysis(analysis) : null
  const progress = progressQuery.data ?? []
  const isPending = analysis?.status === 'pending'

  return (
    <div className="mx-auto max-w-6xl space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <Link
          to="/"
          className="inline-flex items-center gap-2 text-sm font-medium text-text-muted transition hover:text-text-primary"
        >
          <ArrowLeft size={16} />
          Kembali ke dashboard
        </Link>

        <button
          type="button"
          onClick={() => {
            void clientQuery.refetch()
            void analysisQuery.refetch()
            void progressQuery.refetch()
          }}
          className="inline-flex items-center gap-2 rounded-xl border border-border px-3 py-2 text-xs font-semibold text-text-secondary transition hover:bg-surface-alt"
        >
          <RefreshCw size={14} />
          Muat ulang
        </button>
      </div>

      <section className="panel p-6 sm:p-8">
        <div className="flex flex-col gap-5 lg:flex-row lg:items-start lg:justify-between">
          <div>
            <div className="flex flex-wrap items-center gap-3">
              <h2 className="text-2xl font-semibold tracking-tight sm:text-3xl">
                {client.name}
              </h2>
              <StatusBadge status={analysis?.status ?? 'none'} />
            </div>
            <p className="mt-1 text-sm text-text-muted">{client.email}</p>
            <p className="mt-3 text-sm text-text-secondary">
              {client.weight_current} kg sekarang · target {client.weight_target}{' '}
              kg
            </p>
          </div>

          <div className="flex flex-wrap gap-3">
            <button
              type="button"
              onClick={() => setShowGenerate(true)}
              className="inline-flex items-center gap-2 rounded-xl border border-border px-4 py-2.5 text-sm font-semibold text-text-secondary transition hover:bg-surface-alt"
            >
              <Sparkles size={16} />
              Generate Plan
            </button>
            {analysis && (
              <Link
                to={`/clients/${clientId}/review`}
                className="btn-primary"
              >
                <ClipboardCheck size={16} />
                {isPending ? 'Review Rencana' : 'Lihat Rencana'}
              </Link>
            )}
          </div>
        </div>
      </section>

      <div className="grid gap-4 lg:grid-cols-2">
        <section className="panel p-5 sm:p-6">
          <div className="flex items-center gap-3">
            <div className="rounded-xl bg-primary/15 p-2.5 text-accent">
              <Target size={18} />
            </div>
            <div>
              <h3 className="font-semibold">Health Profile</h3>
              <p className="text-xs text-text-muted">Data kesehatan klien</p>
            </div>
          </div>

          <div className="mt-4">
            <InfoRow label="Berat sekarang" value={`${client.weight_current} kg`} />
            <InfoRow label="Target berat" value={`${client.weight_target} kg`} />
            <InfoRow
              label="Tinggi badan"
              value={client.height_cm ? `${client.height_cm} cm` : null}
            />
            <InfoRow label="Alergi" value={client.allergies} />
            <InfoRow label="Jenis kelamin" value={genderLabel(client.gender)} />
            <InfoRow
              label="Tanggal lahir"
              value={client.birth_date ? formatDate(client.birth_date) : null}
            />
            <InfoRow label="Aktivitas" value={client.activity_level} />
          </div>
        </section>

        <section className="panel p-5 sm:p-6">
          <div className="flex items-center gap-3">
            <div className="rounded-xl bg-success/10 p-2.5 text-success">
              <CalendarDays size={18} />
            </div>
            <div>
              <h3 className="font-semibold">Rencana Mingguan</h3>
              <p className="text-xs text-text-muted">
                Status rencana AI terbaru
              </p>
            </div>
          </div>

          {analysisQuery.isLoading ? (
            <div className="mt-4">
              <LoadingSkeleton rows={1} />
            </div>
          ) : !analysis || !plan ? (
            <EmptyState
              icon={Sparkles}
              title="Belum ada rencana"
              description="Generate rencana AI untuk klien ini. Rencana akan menunggu review sebelum diterapkan."
              action={
                <button
                  type="button"
                  onClick={() => setShowGenerate(true)}
                  className="btn-primary"
                >
                  <Sparkles size={16} />
                  Generate Plan
                </button>
              }
            />
          ) : (
            <div className="mt-4 space-y-4">
              <div className="flex flex-wrap items-center justify-between gap-2">
                <div>
                  <p className="text-sm font-semibold">
                    Minggu {formatWeekRange(analysis.week_start_date)}
                  </p>
                  <p className="text-xs text-text-muted">
                    {analysis.reviewed_at
                      ? `Direview ${formatDateTime(analysis.reviewed_at)}`
                      : 'Belum direview'}
                  </p>
                </div>
                <StatusBadge status={analysis.status} />
              </div>

              {isPending && (
                <div className="rounded-xl border border-warning/25 bg-warning/10 px-4 py-3 text-sm text-warning">
                  Rencana ini menunggu keputusanmu. Buka review untuk approve
                  atau override.
                </div>
              )}

              <div className="grid grid-cols-3 gap-2">
                <div className="rounded-xl bg-surface-alt/60 p-3">
                  <p className="text-[10px] font-semibold uppercase tracking-[0.14em] text-text-muted">
                    Langkah
                  </p>
                  <p className="mt-1 text-lg font-semibold">
                    {plan.targets.steps.toLocaleString('id-ID')}
                  </p>
                </div>
                <div className="rounded-xl bg-surface-alt/60 p-3">
                  <p className="text-[10px] font-semibold uppercase tracking-[0.14em] text-text-muted">
                    Air
                  </p>
                  <p className="mt-1 text-lg font-semibold">
                    {plan.targets.water_liters} L
                  </p>
                </div>
                <div className="rounded-xl bg-surface-alt/60 p-3">
                  <p className="text-[10px] font-semibold uppercase tracking-[0.14em] text-text-muted">
                    Kalori
                  </p>
                  <p className="mt-1 text-lg font-semibold">
                    {plan.targets.calories.toLocaleString('id-ID')}
                  </p>
                </div>
              </div>

              <div className="flex flex-wrap gap-4 text-xs text-text-muted">
                <span className="inline-flex items-center gap-1.5">
                  <Dumbbell size={14} className="text-accent" />
                  {plan.workout.length} latihan
                </span>
                <span className="inline-flex items-center gap-1.5">
                  <Utensils size={14} className="text-success" />
                  {plan.meals.length} menu
                </span>
              </div>

              <Link
                to={`/clients/${clientId}/review`}
                className="inline-flex items-center gap-2 text-sm font-semibold text-accent hover:text-accent/80"
              >
                <ClipboardCheck size={16} />
                Buka detail rencana
              </Link>
            </div>
          )}
        </section>
      </div>

      <section className="space-y-4">
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div>
            <h3 className="text-lg font-semibold">Progres Klien</h3>
            <p className="text-xs text-text-muted">
              Grafik berat badan dan langkah harian.
            </p>
          </div>

          <div className="flex rounded-xl border border-border bg-surface p-1">
            {[7, 30, 90].map((days) => (
              <button
                key={days}
                type="button"
                onClick={() => setRangeDays(days)}
                className={`rounded-lg px-3 py-1.5 text-xs font-semibold transition ${
                  rangeDays === days
                    ? 'bg-primary/15 text-accent'
                    : 'text-text-muted hover:text-text-primary'
                }`}
              >
                {days} hari
              </button>
            ))}
          </div>
        </div>

        {progressQuery.isLoading ? (
          <LoadingSkeleton rows={2} />
        ) : progressQuery.isError ? (
          <ErrorState
            message={getErrorMessage(progressQuery.error)}
            onRetry={() => void progressQuery.refetch()}
          />
        ) : (
          <>
            <ProgressCharts data={progress} />

            <div className="panel overflow-hidden">
              <div className="border-b border-border px-5 py-4">
                <h3 className="font-semibold">Riwayat Log</h3>
                <p className="text-xs text-text-muted">
                  {progress.length} catatan pada rentang ini.
                </p>
              </div>

              {progress.length === 0 ? (
                <EmptyState
                  icon={CalendarDays}
                  title="Belum ada log"
                  description="Klien belum mencatat berat atau langkah pada rentang ini."
                />
              ) : (
                <div className="overflow-x-auto">
                  <table className="w-full min-w-[520px] text-left text-sm">
                    <thead className="border-b border-border bg-surface-alt/40 text-xs uppercase tracking-[0.14em] text-text-muted">
                      <tr>
                        <th className="px-5 py-3 font-semibold">Tanggal</th>
                        <th className="px-5 py-3 font-semibold">Berat</th>
                        <th className="px-5 py-3 font-semibold">Langkah</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-border">
                      {[...progress].reverse().map((point) => (
                        <tr key={point.log_date}>
                          <td className="px-5 py-3 text-text-secondary">
                            {formatDate(point.log_date)}
                          </td>
                          <td className="px-5 py-3 text-text-secondary">
                            {point.weight_kg != null
                              ? `${point.weight_kg} kg`
                              : '—'}
                          </td>
                          <td className="px-5 py-3 text-text-secondary">
                            {point.steps.toLocaleString('id-ID')}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          </>
        )}
      </section>

      {showGenerate && (
        <GeneratePlanDialog
          clientName={client.name}
          isPending={generateMutation.isPending}
          onClose={() => setShowGenerate(false)}
          onSubmit={(weekStartDate) =>
            generateMutation.mutate(weekStartDate)
          }
        />
      )}
    </div>
  )
}
