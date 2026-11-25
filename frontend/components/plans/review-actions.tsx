'use client'

import { PenLine } from 'lucide-react'
import { useState } from 'react'
import { ApproveForm } from '@/components/plans/approve-form'
import { PlanEditor } from '@/components/plans/plan-editor'
import type { ClientProfile, Exercise, Food, PlanOutput } from '@/types/api'

export function ReviewActions({
  plan,
  client,
  exercises,
  foods,
  analysisId,
  clientId,
}: {
  plan: PlanOutput
  client: ClientProfile
  exercises: Exercise[]
  foods: Food[]
  analysisId: number
  clientId: number
}) {
  const [showEditor, setShowEditor] = useState(false)

  return (
    <>
      <div className="flex flex-wrap items-start gap-3">
        <button
          type="button"
          onClick={() => setShowEditor(true)}
          className="inline-flex items-center gap-2 rounded-xl border border-border px-4 py-2.5 text-sm font-semibold text-text-secondary transition hover:bg-surface-alt"
        >
          <PenLine size={16} />
          Override
        </button>
        <ApproveForm analysisId={analysisId} clientId={clientId} />
      </div>

      {showEditor && (
        <PlanEditor
          plan={plan}
          client={client}
          exercises={exercises}
          foods={foods}
          analysisId={analysisId}
          clientId={clientId}
        />
      )}
    </>
  )
}
