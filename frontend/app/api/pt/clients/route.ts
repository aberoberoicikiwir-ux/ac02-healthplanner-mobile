import { cookies } from 'next/headers'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

const API_URL = (process.env.API_URL ?? 'http://localhost:3000/api').replace(
  /\/$/,
  '',
)

export async function GET(request: NextRequest) {
  const store = await cookies()
  const token = store.get('hmx_token')?.value

  if (!token) {
    return NextResponse.json({ message: 'Sesi tidak valid.' }, { status: 401 })
  }

  const query = request.nextUrl.searchParams.toString()
  const response = await fetch(
    `${API_URL}/pt/clients${query ? `?${query}` : ''}`,
    {
      headers: {
        Authorization: `Bearer ${token}`,
        Accept: 'application/json',
      },
      cache: 'no-store',
    },
  )

  const body = await response.json()
  return NextResponse.json(body, { status: response.status })
}
