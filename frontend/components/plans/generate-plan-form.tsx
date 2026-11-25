'use client'

import { CalendarDays } from 'lucide-react'
import { useActionState } from 'react'
import { useFormStatus } from 'react-dom'
import { generatePlanAction } from '@/app/(dashboard)/clients/[id]/actions'
import { getNextMonday } from '@/lib/dates'

function SubmitButton() {
  const { pending } = useFormStatus()

  return (
    <button type="submit" disabled={pending} className="btn-primary">
      <CalendarDays size={16} />
      {pending ? 'Membuat rencana...' : 'Generate Plan'}
    </button>
  )
}

export function GeneratePlanForm({ clientId }: { clientId: number }) {
  const [state, formAction] = useActionState(generatePlanAction, {
    error: null,
  })

  return (
    <form action={formAction} className="flex flex-col gap-3">
      <input type="hidden" name="clientId" value={clientId} />
      <label className="block">
        <span className="mb-2 block text-xs font-semibold uppercase tracking-[0.16em] text-text-muted">
          Minggu dimulai
        </span>
        <input
          type="date"
          name="weekStartDate"
          defaultValue={getNextMonday()}
          className="input"
        />
      </label>

      {state.error && (
        <p className="rounded-xl border border-danger/30 bg-danger/10 px-3 py-2 text-sm text-danger">
          {state.error}
        </p>
      )}

      <SubmitButton />
    </form>
  )
}
