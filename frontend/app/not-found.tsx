import Link from 'next/link'

export default function NotFound() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-background px-6 text-text-primary">
      <div className="panel max-w-md p-8 text-center">
        <p className="text-xs font-semibold uppercase tracking-[0.22em] text-accent">
          404
        </p>
        <h1 className="mt-2 text-2xl font-semibold">Halaman tidak ditemukan</h1>
        <p className="mt-3 text-sm leading-6 text-text-muted">
          Data atau halaman yang kamu cari tidak tersedia.
        </p>
        <Link href="/" className="btn-primary mt-6">
          Kembali ke dashboard
        </Link>
      </div>
    </div>
  )
}
