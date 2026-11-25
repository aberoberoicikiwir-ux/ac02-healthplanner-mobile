const dateFormatter = new Intl.DateTimeFormat('id-ID', {
  day: 'numeric',
  month: 'short',
  year: 'numeric',
})

const dateTimeFormatter = new Intl.DateTimeFormat('id-ID', {
  day: 'numeric',
  month: 'short',
  year: 'numeric',
  hour: '2-digit',
  minute: '2-digit',
})

const shortDateFormatter = new Intl.DateTimeFormat('id-ID', {
  day: '2-digit',
  month: 'short',
})

export function toIsoDate(date: Date): string {
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}

export function parseIsoDate(value: string): Date {
  const [year, month, day] = value.split('-').map(Number)
  return new Date(year, (month || 1) - 1, day || 1)
}

export function addDays(date: Date, days: number): Date {
  const copy = new Date(date)
  copy.setDate(copy.getDate() + days)
  return copy
}

export function getDateRange(days: number): { from: string; to: string } {
  const to = new Date()
  const from = addDays(to, -(days - 1))
  return { from: toIsoDate(from), to: toIsoDate(to) }
}

export function getNextMonday(): string {
  const today = new Date()
  const daysUntilMonday = (8 - today.getDay()) % 7 || 7
  return toIsoDate(addDays(today, daysUntilMonday))
}

export function getCurrentWeekStart(): string {
  const today = new Date()
  const daysSinceMonday = (today.getDay() + 6) % 7
  return toIsoDate(addDays(today, -daysSinceMonday))
}

export function formatDate(value: string | null | undefined): string {
  if (!value) return '—'
  return dateFormatter.format(parseIsoDate(value.slice(0, 10)))
}

export function formatDateTime(value: string | null | undefined): string {
  if (!value) return '—'
  return dateTimeFormatter.format(new Date(value))
}

export function formatShortDate(value: string): string {
  return shortDateFormatter.format(parseIsoDate(value))
}

export function formatWeekRange(start: string): string {
  const startDate = parseIsoDate(start)
  const endDate = addDays(startDate, 6)
  return `${formatDate(start)} – ${formatDate(toIsoDate(endDate))}`
}
