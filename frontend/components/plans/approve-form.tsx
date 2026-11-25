'use client'

import { CheckCircle2 } from 'lucide-react'
import { useActionState } from 'react'
import { useFormStatus } from 'react-dom'
import { approveAction } from '@/app/(dashboard)/clients/[id]/actions'

function SubmitButton() {
  const { pending } = useFormStatus()

  return (
    <button type="submit" disabled={pending} className="btn-primary">
      <CheckCircle2 size={16} />
      {pending ? 'Menerapkan...' : 'Setujui Rencana'}
    </button>
  )
}

export function ApproveForm({
  analysisId,
  clientId,
}: {
  analysisId: number
  clientId: number
}) {
  const [state, formAction] = useActionState(approveAction, { error: null })

  return (
    <form action={formAction} className="space-y-3">
      <input type="hidden" name="analysisId" value={analysisId} />
      <input type="hidden" name="clientId" value={clientId} />

      {state.error && (
        <p className="rounded-xl border border-danger/30 bg-danger/10 px-3 py-2 text-sm text-danger">
          {state.error}
        </p>
      )}

      <SubmitButton />
    </form>
  )
}
