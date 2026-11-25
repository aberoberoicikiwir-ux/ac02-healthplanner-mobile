'use client'

import { Activity, Scale } from 'lucide-react'
import { useMemo } from 'react'
import {
  Bar,
  BarChart,
  CartesianGrid,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts'
import { EmptyState } from '@/components/ui/empty-state'
import { formatShortDate } from '@/lib/dates'
import type { ProgressPoint } from '@/types/api'

const tooltipStyle = {
  backgroundColor: '#151C24',
  border: '1px solid #2B3644',
  borderRadius: 12,
  color: '#F8FAFC',
}

export function ProgressCharts({ data }: { data: ProgressPoint[] }) {
  const weightData = useMemo(
    () => data.filter((point) => point.weight_kg !== null),
    [data],
  )

  return (
    <div className="grid gap-4 xl:grid-cols-2">
      <section className="panel p-5">
        <div className="flex items-center gap-3">
          <div className="rounded-xl bg-primary/15 p-2.5 text-accent">
            <Scale size={18} />
          </div>
          <div>
            <h3 className="font-semibold">Berat Badan</h3>
            <p className="text-xs text-text-muted">Perubahan berat klien</p>
          </div>
        </div>

        {weightData.length === 0 ? (
          <EmptyState
            icon={Scale}
            title="Belum ada data berat"
            description="Data akan muncul setelah klien mencatat berat badannya."
          />
        ) : (
          <div className="mt-5 h-64">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={weightData}>
                <CartesianGrid stroke="#2B3644" strokeDasharray="4 4" />
                <XAxis
                  dataKey="log_date"
                  tickFormatter={formatShortDate}
                  stroke="#94A3B8"
                  fontSize={12}
                  tickLine={false}
                  axisLine={false}
                />
                <YAxis
                  stroke="#94A3B8"
                  fontSize={12}
                  tickLine={false}
                  axisLine={false}
                  width={42}
                  domain={['dataMin - 1', 'dataMax + 1']}
                />
                <Tooltip
                  contentStyle={tooltipStyle}
                  labelFormatter={(label) => formatShortDate(String(label))}
                  formatter={(value) => [`${value} kg`, 'Berat']}
                />
                <Line
                  type="monotone"
                  dataKey="weight_kg"
                  stroke="#64FFDA"
                  strokeWidth={2.5}
                  dot={{ fill: '#64FFDA', r: 3 }}
                  activeDot={{ r: 5 }}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        )}
      </section>

      <section className="panel p-5">
        <div className="flex items-center gap-3">
          <div className="rounded-xl bg-success/10 p-2.5 text-success">
            <Activity size={18} />
          </div>
          <div>
            <h3 className="font-semibold">Langkah Harian</h3>
            <p className="text-xs text-text-muted">Aktivitas harian klien</p>
          </div>
        </div>

        {data.length === 0 ? (
          <EmptyState
            icon={Activity}
            title="Belum ada data langkah"
            description="Data akan muncul setelah klien mencatat aktivitasnya."
          />
        ) : (
          <div className="mt-5 h-64">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={data}>
                <CartesianGrid stroke="#2B3644" strokeDasharray="4 4" />
                <XAxis
                  dataKey="log_date"
                  tickFormatter={formatShortDate}
                  stroke="#94A3B8"
                  fontSize={12}
                  tickLine={false}
                  axisLine={false}
                />
                <YAxis
                  stroke="#94A3B8"
                  fontSize={12}
                  tickLine={false}
                  axisLine={false}
                  width={48}
                />
                <Tooltip
                  contentStyle={tooltipStyle}
                  labelFormatter={(label) => formatShortDate(String(label))}
                  formatter={(value) => [
                    Number(value).toLocaleString('id-ID'),
                    'Langkah',
                  ]}
                />
                <Bar dataKey="steps" fill="#4ADE80" radius={[6, 6, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        )}
      </section>
    </div>
  )
}
