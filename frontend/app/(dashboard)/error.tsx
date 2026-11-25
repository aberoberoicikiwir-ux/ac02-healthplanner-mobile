'use client'

import { AlertTriangle, RefreshCw } from 'lucide-react'

export default function DashboardError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <div className="panel mx-auto flex max-w-2xl flex-col items-center px-6 py-12 text-center">
      <div className="rounded-2xl bg-danger/10 p-4 text-danger">
        <AlertTriangle size={26} />
      </div>
      <h2 className="mt-4 text-lg font-semibold">Gagal memuat halaman</h2>
      <p className="mt-2 max-w-lg text-sm leading-6 text-text-muted">
        {error.message || 'Terjadi kesalahan saat mengambil data.'}
      </p>
      <button type="button" onClick={reset} className="btn-primary mt-5">
        <RefreshCw size={16} />
        Coba lagi
      </button>
    </div>
  )
}
