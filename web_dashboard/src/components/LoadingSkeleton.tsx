export function LoadingSkeleton({
  rows = 3,
  className = '',
}: {
  rows?: number
  className?: string
}) {
  return (
    <div className={`space-y-3 ${className}`}>
      {Array.from({ length: rows }).map((_, index) => (
        <div
          key={index}
          className="animate-pulse rounded-2xl border border-border bg-surface/70 p-5"
        >
          <div className="h-4 w-1/3 rounded bg-surface-alt" />
          <div className="mt-3 h-3 w-2/3 rounded bg-surface-alt" />
          <div className="mt-2 h-3 w-1/2 rounded bg-surface-alt" />
        </div>
      ))}
    </div>
  )
}
