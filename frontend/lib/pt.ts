import 'server-only'
import { ApiError, apiFetch } from './api'
import type {
  AiAnalysis,
  ClientProfile,
  Exercise,
  Food,
  NotificationItem,
  PaginatedClients,
  PlanOutput,
  ProgressPoint,
} from '@/types/api'

export function getClientsPage(
  token: string,
  params: {
    page: number
    limit: number
    search?: string
    status?: string
    sort?: string
    order?: string
  },
) {
  const query = new URLSearchParams({
    page: String(params.page),
    limit: String(params.limit),
    status: params.status ?? 'active',
    sort: params.sort ?? 'name',
    order: params.order ?? 'asc',
  })

  if (params.search) query.set('search', params.search)

  return apiFetch<PaginatedClients>(`/pt/clients?${query.toString()}`, token)
}

export function getClient(clientId: number | string, token: string) {
  return apiFetch<ClientProfile>(`/pt/clients/${clientId}`, token)
}

export function getClientProgress(
  clientId: number | string,
  from: string,
  to: string,
  token: string,
) {
  const query = new URLSearchParams({ from, to })
  return apiFetch<ProgressPoint[]>(
    `/pt/clients/${clientId}/progress?${query.toString()}`,
    token,
  )
}

export async function getCurrentAnalysis(
  clientId: number | string,
  token: string,
): Promise<AiAnalysis | null> {
  try {
    return await apiFetch<AiAnalysis>(
      `/pt/clients/${clientId}/ai-analysis/current`,
      token,
    )
  } catch (error) {
    if (error instanceof ApiError && error.status === 404) return null
    throw error
  }
}

export function getNotifications(token: string) {
  return apiFetch<NotificationItem[]>('/users/me/notifications', token)
}

export function markNotificationRead(notificationId: number, token: string) {
  return apiFetch<{ message: string }>(
    `/notifications/${notificationId}/read`,
    token,
    { method: 'PATCH' },
  )
}

export function getExercises(token: string) {
  return apiFetch<Exercise[]>('/exercises', token)
}

export function getFoods(token: string) {
  return apiFetch<Food[]>('/foods', token)
}

export function generatePlan(
  clientId: number | string,
  weekStartDate: string,
  token: string,
) {
  return apiFetch<{ message: string; analysis_id?: number }>(
    `/pt/clients/${clientId}/generate-plan`,
    token,
    {
      method: 'POST',
      body: JSON.stringify({ week_start_date: weekStartDate }),
    },
  )
}

export function approveAnalysis(analysisId: number, token: string) {
  return apiFetch<{ message: string }>(
    `/pt/ai-analysis/${analysisId}/approve`,
    token,
    { method: 'PATCH' },
  )
}

export function overrideAnalysis(
  analysisId: number,
  finalOutput: PlanOutput,
  token: string,
) {
  return apiFetch<{ message: string }>(
    `/pt/ai-analysis/${analysisId}/override`,
    token,
    {
      method: 'PATCH',
      body: JSON.stringify({
        final_output: {
          feedback: finalOutput.feedback,
          targets: finalOutput.targets,
          workout: finalOutput.workout,
          meals: finalOutput.meals,
        },
      }),
    },
  )
}
