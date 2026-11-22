import { ApiError } from '../api/client'

export function getErrorMessage(error: unknown): string {
  if (error instanceof ApiError) {
    const details = error.payload?.details

    if (Array.isArray(details) && details.length > 0) {
      return `${error.message} ${details.map(String).join(' ')}`.trim()
    }

    return error.message
  }

  if (error instanceof Error) {
    return error.message
  }

  return 'Terjadi kesalahan. Coba lagi.'
}
