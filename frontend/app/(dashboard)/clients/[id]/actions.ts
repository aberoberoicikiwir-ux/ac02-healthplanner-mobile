'use server'

import { revalidatePath } from 'next/cache'
import { redirect } from 'next/navigation'
import { ApiError } from '@/lib/api'
import {
  approveAnalysis,
  generatePlan,
  overrideAnalysis,
} from '@/lib/pt'
import { requireSession } from '@/lib/session'
import type { PlanOutput } from '@/types/api'

export interface ActionState {
  error: string | null
}

function errorMessage(error: unknown) {
  if (error instanceof ApiError) return error.message
  if (error instanceof Error) return error.message
  return 'Terjadi kesalahan. Coba lagi.'
}

function refreshClientPaths(clientId: string) {
  revalidatePath('/')
  revalidatePath(`/clients/${clientId}`)
  revalidatePath(`/clients/${clientId}/review`)
  revalidatePath('/notifications')
}

export async function generatePlanAction(
  _previousState: ActionState,
  formData: FormData,
): Promise<ActionState> {
  const session = await requireSession()
  const clientId = String(formData.get('clientId') ?? '')
  const weekStartDate = String(formData.get('weekStartDate') ?? '')

  if (!clientId || !weekStartDate) {
    return { error: 'Data generate rencana belum lengkap.' }
  }

  let success = false

  try {
    await generatePlan(clientId, weekStartDate, session.token)
    success = true
  } catch (error) {
    return { error: errorMessage(error) }
  }

  if (success) {
    refreshClientPaths(clientId)
    redirect(`/clients/${clientId}/review`)
  }

  return { error: null }
}

export async function approveAction(
  _previousState: ActionState,
  formData: FormData,
): Promise<ActionState> {
  const session = await requireSession()
  const analysisId = Number(formData.get('analysisId'))
  const clientId = String(formData.get('clientId') ?? '')

  if (!Number.isInteger(analysisId) || analysisId < 1 || !clientId) {
    return { error: 'Data analisis tidak valid.' }
  }

  let success = false

  try {
    await approveAnalysis(analysisId, session.token)
    success = true
  } catch (error) {
    return { error: errorMessage(error) }
  }

  if (success) {
    refreshClientPaths(clientId)
    redirect(`/clients/${clientId}`)
  }

  return { error: null }
}

export async function overrideAction(
  _previousState: ActionState,
  formData: FormData,
): Promise<ActionState> {
  const session = await requireSession()
  const analysisId = Number(formData.get('analysisId'))
  const clientId = String(formData.get('clientId') ?? '')
  const rawPlan = String(formData.get('finalOutput') ?? '')

  if (!Number.isInteger(analysisId) || analysisId < 1 || !clientId) {
    return { error: 'Data analisis tidak valid.' }
  }

  let finalOutput: PlanOutput

  try {
    finalOutput = JSON.parse(rawPlan) as PlanOutput
  } catch {
    return { error: 'Format rencana override tidak valid.' }
  }

  if (!finalOutput || typeof finalOutput !== 'object') {
    return { error: 'Rencana override tidak valid.' }
  }

  let success = false

  try {
    await overrideAnalysis(analysisId, finalOutput, session.token)
    success = true
  } catch (error) {
    return { error: errorMessage(error) }
  }

  if (success) {
    refreshClientPaths(clientId)
    redirect(`/clients/${clientId}`)
  }

  return { error: null }
}
