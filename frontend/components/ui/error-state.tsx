import { AlertTriangle } from 'lucide-react'

export function ErrorState({ message }: { message: string }) {
  return (
    <div className="panel flex flex-col items-center justify-center px-6 py-12 text-center">
      <div className="rounded-2xl bg-danger/10 p-4 text-danger">
        <AlertTriangle size={26} />
      </div>
      <h3 className="mt-4 text-lg font-semibold">Gagal memuat data</h3>
      <p className="mt-2 max-w-lg text-sm leading-6 text-text-muted">
        {message}
      </p>
    </div>
  )
}
