export default function DashboardLoading() {
  return (
    <div className="mx-auto max-w-6xl space-y-6">
      <div className="panel h-40 animate-pulse" />
      <div className="grid gap-4 sm:grid-cols-3">
        <div className="panel h-28 animate-pulse" />
        <div className="panel h-28 animate-pulse" />
        <div className="panel h-28 animate-pulse" />
      </div>
      <div className="panel h-72 animate-pulse" />
    </div>
  )
}
