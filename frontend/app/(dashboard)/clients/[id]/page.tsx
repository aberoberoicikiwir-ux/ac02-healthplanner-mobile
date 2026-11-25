import type { Metadata } from 'next'
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
import Link from 'next/link'
import { notFound } from 'next/navigation'
import { ProgressCharts } from '@/components/charts/progress-charts'
import { EmptyState } from '@/components/ui/empty-state'
import { StatusBadge } from '@/components/ui/status-badge'
import { GeneratePlanForm } from '@/components/plans/generate-plan-form'
import { ApiError } from '@/lib/api'
import {
  formatDate,
  formatDateTime,
  formatWeekRange,
  getDateRange,
} from '@/lib/dates'
import { getPlanFromAnalysis } from '@/lib/plan'
import {
  getClient,
  getClientProgress,
  getCurrentAnalysis,
} from '@/lib/pt'
import { requireSession } from '@/lib/session'
import type { ClientProfile } from '@/types/api'

export const metadata: Metadata = {
  title: 'Detail Klien',
}

type SearchParams = Promise<Record<string, string | string[] | undefined>>

function first(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] : value
}

function genderLabel(gender: ClientProfile['gender']) {
  if (gender === 'male') return 'Laki-laki'
  if (gender === 'female') return 'Perempuan'
  return '—'
}

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

export default async function ClientDetailPage({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>
  searchParams: SearchParams
}) {
  const { id } = await params
  const query = await searchParams
  const clientId = Number(id)

  if (!Number.isInteger(clientId) || clientId < 1) notFound()

  const session = await requireSession()
  const rangeValue = Number(first(query.range) ?? 30)
  const rangeDays = [7, 30, 90].includes(rangeValue) ? rangeValue : 30
  const { from, to } = getDateRange(rangeDays)

  let client: ClientProfile
  try {
    client = await getClient(clientId, session.token)
  } catch (error) {
    if (error instanceof ApiError && error.status === 404) notFound()
    throw error
  }

  const [analysis, progress] = await Promise.all([
    getCurrentAnalysis(clientId, session.token),
    getClientProgress(clientId, from, to, session.token),
  ])
  const plan = analysis ? getPlanFromAnalysis(analysis) : null
  const isPending = analysis?.status === 'pending'

  return (
    <div className="mx-auto max-w-6xl space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <Link
          href="/"
          className="inline-flex items-center gap-2 text-sm font-medium text-text-muted transition hover:text-text-primary"
        >
          <ArrowLeft size={16} />
          Kembali ke dashboard
        </Link>

        <Link
          href={`/clients/${clientId}?range=${rangeDays}`}
          className="inline-flex items-center gap-2 rounded-xl border border-border px-3 py-2 text-xs font-semibold text-text-secondary transition hover:bg-surface-alt"
        >
          <RefreshCw size={14} />
          Muat ulang
        </Link>
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
            <a
              href="#generate-plan"
              className="inline-flex items-center gap-2 rounded-xl border border-border px-4 py-2.5 text-sm font-semibold text-text-secondary transition hover:bg-surface-alt"
            >
              <Sparkles size={16} />
              Generate Plan
            </a>
            {analysis && (
              <Link
                href={`/clients/${clientId}/review`}
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
            <InfoRow
              label="Berat sekarang"
              value={`${client.weight_current} kg`}
            />
            <InfoRow
              label="Target berat"
              value={`${client.weight_target} kg`}
            />
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

          {!analysis || !plan ? (
            <EmptyState
              icon={Sparkles}
              title="Belum ada rencana"
              description="Generate rencana AI untuk klien ini. Rencana akan menunggu review sebelum diterapkan."
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
                href={`/clients/${clientId}/review`}
                className="inline-flex items-center gap-2 text-sm font-semibold text-accent hover:text-accent/80"
              >
                <ClipboardCheck size={16} />
                Buka detail rencana
              </Link>
            </div>
          )}
        </section>
      </div>

      <details id="generate-plan" className="panel p-5 sm:p-6">
        <summary className="cursor-pointer list-none text-sm font-semibold text-accent">
          Generate rencana AI
        </summary>
        <p className="mt-2 text-xs leading-6 text-text-muted">
          Rencana baru akan berstatus pending dan belum terlihat oleh klien
          sebelum disetujui.
        </p>
        <div className="mt-4 max-w-sm">
          <GeneratePlanForm clientId={clientId} />
        </div>
      </details>

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
              <Link
                key={days}
                href={`/clients/${clientId}?range=${days}`}
                className={`rounded-lg px-3 py-1.5 text-xs font-semibold transition ${
                  rangeDays === days
                    ? 'bg-primary/15 text-accent'
                    : 'text-text-muted hover:text-text-primary'
                }`}
              >
                {days} hari
              </Link>
            ))}
          </div>
        </div>

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
              <table
                className="w-full text-left text-sm"
                style={{ minWidth: '520px' }}
              >
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
                        {point.weight_kg != null ? `${point.weight_kg} kg` : '—'}
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
      </section>
    </div>
  )
}
