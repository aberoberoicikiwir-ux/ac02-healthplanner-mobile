import type {
  AiAnalysis,
  ClientProfile,
  PlanOutput,
  PlanReviewResponse,
  ProgressPoint,
  PtClient,
} from '../types/api'
import { ApiError, apiRequest } from './client'

export function getClients() {
  return apiRequest<PtClient[]>('/pt/clients?status=active')
}

export function getClient(clientId: number | string) {
  return apiRequest<ClientProfile>(`/pt/clients/${clientId}`)
}

export function getClientProgress(
  clientId: number | string,
  from: string,
  to: string,
) {
  const params = new URLSearchParams({ from, to })
  return apiRequest<ProgressPoint[]>(
    `/pt/clients/${clientId}/progress?${params.toString()}`,
  )
}

export async function getCurrentAnalysis(
  clientId: number | string,
): Promise<AiAnalysis | null> {
  try {
    return await apiRequest<AiAnalysis>(
      `/pt/clients/${clientId}/ai-analysis/current`,
    )
  } catch (error) {
    if (error instanceof ApiError && error.status === 404) {
      return null
    }

    throw error
  }
}

export function generatePlan(clientId: number | string, weekStartDate?: string) {
  return apiRequest<{ message: string; analysis_id?: number }>(
    `/pt/clients/${clientId}/generate-plan`,
    {
      method: 'POST',
      body: JSON.stringify(
        weekStartDate ? { week_start_date: weekStartDate } : {},
      ),
    },
  )
}

export function approveAnalysis(analysisId: number) {
  return apiRequest<PlanReviewResponse>(
    `/pt/ai-analysis/${analysisId}/approve`,
    { method: 'PATCH' },
  )
}

export function overrideAnalysis(analysisId: number, finalOutput: PlanOutput) {
  return apiRequest<PlanReviewResponse>(
    `/pt/ai-analysis/${analysisId}/override`,
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
