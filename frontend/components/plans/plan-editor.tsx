'use client'

import { AlertTriangle, Plus, Save, Trash2, X } from 'lucide-react'
import { useRouter } from 'next/navigation'
import { useActionState, useState } from 'react'
import type { FormEvent } from 'react'
import { useFormStatus } from 'react-dom'
import { overrideAction } from '@/app/(dashboard)/clients/[id]/actions'
import {
  DAYS,
  DAY_LABELS,
  MEAL_LABELS,
  MEAL_TYPES,
  REQUIRED_MEALS,
  clonePlan,
  getExercise,
  isTimedCategory,
  validatePlanDraft,
} from '@/lib/plan'
import type {
  ClientProfile,
  Day,
  Exercise,
  Food,
  MealPlanItem,
  MealType,
  PlanOutput,
  WorkoutPlanItem,
} from '@/types/api'

function SubmitButton() {
  const { pending } = useFormStatus()

  return (
    <button type="submit" disabled={pending} className="btn-primary">
      <Save size={16} />
      {pending ? 'Menyimpan...' : 'Simpan Override'}
    </button>
  )
}

export function PlanEditor({
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
  const router = useRouter()
  const [draft, setDraft] = useState<PlanOutput>(() => clonePlan(plan))
  const [errors, setErrors] = useState<string[]>([])
  const [state, formAction] = useActionState(overrideAction, { error: null })

  function updateTarget(key: keyof PlanOutput['targets'], value: number) {
    setDraft((current) => ({
      ...current,
      targets: { ...current.targets, [key]: value },
    }))
  }

  function updateWorkout(index: number, patch: Partial<WorkoutPlanItem>) {
    setDraft((current) => ({
      ...current,
      workout: current.workout.map((item, itemIndex) =>
        itemIndex === index ? { ...item, ...patch } : item,
      ),
    }))
  }

  function addWorkout(day: Day) {
    const firstExercise = exercises[0]
    if (!firstExercise) return

    const timed = isTimedCategory(firstExercise.category)
    setDraft((current) => ({
      ...current,
      workout: [
        ...current.workout,
        {
          day,
          exercise_id: firstExercise.exercise_id,
          sets: timed ? 1 : 3,
          reps: timed ? 30 : 10,
        },
      ],
    }))
  }

  function removeWorkout(index: number) {
    setDraft((current) => ({
      ...current,
      workout: current.workout.filter((_, itemIndex) => itemIndex !== index),
    }))
  }

  function handleExerciseChange(index: number, exerciseId: number) {
    const exercise = getExercise(exerciseId, exercises)
    const timed = isTimedCategory(exercise?.category)

    updateWorkout(index, {
      exercise_id: exerciseId,
      sets: timed ? 1 : 3,
      reps: timed ? 30 : 10,
    })
  }

  function updateMeal(index: number, patch: Partial<MealPlanItem>) {
    setDraft((current) => ({
      ...current,
      meals: current.meals.map((item, itemIndex) =>
        itemIndex === index ? { ...item, ...patch } : item,
      ),
    }))
  }

  function addMeal(day: Day, mealType: MealType) {
    const firstFood = foods[0]
    if (!firstFood) return

    setDraft((current) => ({
      ...current,
      meals: [
        ...current.meals,
        { day, meal_type: mealType, food_id: firstFood.food_id },
      ],
    }))
  }

  function removeMeal(index: number) {
    setDraft((current) => ({
      ...current,
      meals: current.meals.filter((_, itemIndex) => itemIndex !== index),
    }))
  }

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    const validationErrors = validatePlanDraft(
      draft,
      client,
      exercises,
      foods,
    )

    if (validationErrors.length > 0) {
      event.preventDefault()
      setErrors(validationErrors)
      return
    }

    setErrors([])
  }

  const finalOutput = JSON.stringify({
    feedback: draft.feedback,
    targets: draft.targets,
    workout: draft.workout,
    meals: draft.meals,
  })

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto bg-black/70 p-3 backdrop-blur-sm sm:p-6">
      <form
        action={formAction}
        onSubmit={handleSubmit}
        className="mx-auto flex min-h-full w-full max-w-6xl flex-col overflow-hidden rounded-2xl border border-border bg-background shadow-2xl"
      >
        <input type="hidden" name="analysisId" value={analysisId} />
        <input type="hidden" name="clientId" value={clientId} />
        <input type="hidden" name="finalOutput" value={finalOutput} />

        <header className="sticky top-0 z-10 flex items-start justify-between gap-4 border-b border-border bg-background/95 px-4 py-4 backdrop-blur sm:px-6">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.22em] text-accent">
              Override Rencana
            </p>
            <h2 className="mt-1 text-xl font-semibold">{client.name}</h2>
            <p className="mt-1 text-xs text-text-muted">
              Edit rencana sebelum diterapkan ke klien.
            </p>
          </div>
          <button
            type="button"
            onClick={() => router.push(`/clients/${clientId}/review`)}
            className="rounded-lg p-2 text-text-muted transition hover:bg-surface-alt hover:text-text-primary"
            aria-label="Tutup editor"
          >
            <X size={20} />
          </button>
        </header>

        <div className="flex-1 space-y-5 px-4 py-5 sm:px-6">
          {state.error && (
            <section className="rounded-2xl border border-danger/30 bg-danger/10 p-4 text-sm text-danger">
              {state.error}
            </section>
          )}

          {errors.length > 0 && (
            <section className="rounded-2xl border border-danger/30 bg-danger/10 p-4">
              <div className="flex items-center gap-2 text-sm font-semibold text-danger">
                <AlertTriangle size={16} />
                Periksa kembali rencana
              </div>
              <ul className="mt-2 max-h-40 space-y-1 overflow-y-auto text-sm leading-6 text-danger/90">
                {errors.map((error, index) => (
                  <li key={`${index}-${error}`}>• {error}</li>
                ))}
              </ul>
            </section>
          )}

          <section className="panel p-5">
            <label className="block">
              <span className="mb-2 block text-xs font-semibold uppercase tracking-[0.16em] text-text-muted">
                Feedback untuk klien
              </span>
              <textarea
                className="input min-h-28 resize-y"
                value={draft.feedback}
                onChange={(event) =>
                  setDraft((current) => ({
                    ...current,
                    feedback: event.target.value,
                  }))
                }
              />
            </label>

            <div className="mt-4 grid gap-3 sm:grid-cols-3">
              <label className="block">
                <span className="mb-2 block text-xs font-semibold uppercase tracking-[0.16em] text-text-muted">
                  Langkah
                </span>
                <input
                  className="input"
                  type="number"
                  min={1000}
                  max={30000}
                  value={draft.targets.steps}
                  onChange={(event) =>
                    updateTarget('steps', Number(event.target.value))
                  }
                />
              </label>
              <label className="block">
                <span className="mb-2 block text-xs font-semibold uppercase tracking-[0.16em] text-text-muted">
                  Air (liter)
                </span>
                <input
                  className="input"
                  type="number"
                  min={0.5}
                  max={6}
                  step={0.1}
                  value={draft.targets.water_liters}
                  onChange={(event) =>
                    updateTarget('water_liters', Number(event.target.value))
                  }
                />
              </label>
              <label className="block">
                <span className="mb-2 block text-xs font-semibold uppercase tracking-[0.16em] text-text-muted">
                  Kalori
                </span>
                <input
                  className="input"
                  type="number"
                  min={1200}
                  max={4500}
                  value={draft.targets.calories}
                  onChange={(event) =>
                    updateTarget('calories', Number(event.target.value))
                  }
                />
              </label>
            </div>
          </section>

          <section>
            <div className="mb-3">
              <h3 className="text-lg font-semibold">Workout</h3>
              <p className="text-xs text-text-muted">
                Maksimal 4 latihan per hari dan 6 hari latihan.
              </p>
            </div>

            <div className="grid gap-3 xl:grid-cols-2">
              {DAYS.map((day) => {
                const rows = draft.workout
                  .map((item, index) => ({ item, index }))
                  .filter((row) => row.item.day === day)

                return (
                  <div key={day} className="panel p-4">
                    <div className="flex items-center justify-between gap-3">
                      <h4 className="font-semibold">{DAY_LABELS[day]}</h4>
                      <button
                        type="button"
                        onClick={() => addWorkout(day)}
                        disabled={exercises.length === 0}
                        className="inline-flex items-center gap-1.5 rounded-lg border border-border px-2.5 py-1.5 text-xs font-semibold text-text-secondary transition hover:bg-surface-alt disabled:opacity-50"
                      >
                        <Plus size={14} />
                        Tambah
                      </button>
                    </div>

                    {rows.length === 0 ? (
                      <p className="mt-3 text-sm text-text-muted">
                        Hari istirahat / belum ada latihan.
                      </p>
                    ) : (
                      <div className="mt-3 space-y-2">
                        {rows.map(({ item, index }) => {
                          const exercise = getExercise(
                            item.exercise_id,
                            exercises,
                          )
                          const timed = isTimedCategory(exercise?.category)

                          return (
                            <div
                              key={`${day}-${index}`}
                              className="grid gap-2 rounded-xl bg-surface-alt/60 p-3 sm:grid-cols-[minmax(0,1fr)_74px_74px_36px]"
                            >
                              <label className="block">
                                <span className="mb-1 block text-[10px] font-semibold uppercase tracking-[0.14em] text-text-muted">
                                  Latihan
                                </span>
                                <select
                                  className="input px-3 py-2"
                                  value={item.exercise_id}
                                  onChange={(event) =>
                                    handleExerciseChange(
                                      index,
                                      Number(event.target.value),
                                    )
                                  }
                                >
                                  {exercises.map((option) => (
                                    <option
                                      key={option.exercise_id}
                                      value={option.exercise_id}
                                    >
                                      {option.name}
                                    </option>
                                  ))}
                                </select>
                              </label>

                              <label className="block">
                                <span className="mb-1 block text-[10px] font-semibold uppercase tracking-[0.14em] text-text-muted">
                                  Sets
                                </span>
                                <input
                                  className="input px-3 py-2"
                                  type="number"
                                  min={1}
                                  max={6}
                                  disabled={timed}
                                  value={timed ? 1 : item.sets}
                                  onChange={(event) =>
                                    updateWorkout(index, {
                                      sets: Number(event.target.value),
                                    })
                                  }
                                />
                              </label>

                              <label className="block">
                                <span className="mb-1 block text-[10px] font-semibold uppercase tracking-[0.14em] text-text-muted">
                                  {timed ? 'Menit' : 'Reps'}
                                </span>
                                <input
                                  className="input px-3 py-2"
                                  type="number"
                                  min={timed ? 5 : 1}
                                  max={timed ? 90 : 30}
                                  value={item.reps}
                                  onChange={(event) =>
                                    updateWorkout(index, {
                                      reps: Number(event.target.value),
                                    })
                                  }
                                />
                              </label>

                              <button
                                type="button"
                                onClick={() => removeWorkout(index)}
                                className="mt-5 inline-flex h-9 w-9 items-center justify-center rounded-lg text-text-muted transition hover:bg-danger/10 hover:text-danger"
                                aria-label="Hapus latihan"
                              >
                                <Trash2 size={16} />
                              </button>
                            </div>
                          )
                        })}
                      </div>
                    )}
                  </div>
                )
              })}
            </div>
          </section>

          <section>
            <div className="mb-3">
              <h3 className="text-lg font-semibold">Meal</h3>
              <p className="text-xs text-text-muted">
                Sarapan, makan siang, dan makan malam wajib ada setiap hari.
              </p>
            </div>

            <div className="grid gap-3 xl:grid-cols-2">
              {DAYS.map((day) => (
                <div key={day} className="panel p-4">
                  <h4 className="font-semibold">{DAY_LABELS[day]}</h4>

                  <div className="mt-3 space-y-3">
                    {MEAL_TYPES.map((mealType) => {
                      const rows = draft.meals
                        .map((item, index) => ({ item, index }))
                        .filter(
                          (row) =>
                            row.item.day === day &&
                            row.item.meal_type === mealType,
                        )
                      const required = REQUIRED_MEALS.includes(mealType)

                      return (
                        <div
                          key={`${day}-${mealType}`}
                          className="rounded-xl bg-surface-alt/50 p-3"
                        >
                          <div className="flex items-center justify-between gap-3">
                            <div className="flex items-center gap-2">
                              <span className="text-xs font-semibold uppercase tracking-[0.14em] text-text-muted">
                                {MEAL_LABELS[mealType]}
                              </span>
                              {required && (
                                <span className="rounded-full bg-warning/10 px-2 py-0.5 text-[10px] font-semibold text-warning">
                                  Wajib
                                </span>
                              )}
                            </div>
                            <button
                              type="button"
                              onClick={() => addMeal(day, mealType)}
                              disabled={foods.length === 0}
                              className="inline-flex items-center gap-1 text-xs font-semibold text-accent transition hover:text-accent/80 disabled:opacity-50"
                            >
                              <Plus size={14} />
                              Tambah
                            </button>
                          </div>

                          {rows.length === 0 ? (
                            <p className="mt-2 text-xs text-text-muted">
                              Belum ada makanan.
                            </p>
                          ) : (
                            <div className="mt-2 space-y-2">
                              {rows.map(({ item, index }) => (
                                <div
                                  key={`${day}-${mealType}-${index}`}
                                  className="grid gap-2 sm:grid-cols-[minmax(0,1fr)_36px]"
                                >
                                  <select
                                    className="input px-3 py-2"
                                    value={item.food_id}
                                    onChange={(event) =>
                                      updateMeal(index, {
                                        food_id: Number(event.target.value),
                                      })
                                    }
                                  >
                                    {foods.map((food) => (
                                      <option
                                        key={food.food_id}
                                        value={food.food_id}
                                      >
                                        {food.name}
                                        {food.calories != null
                                          ? ` · ${food.calories} kkal`
                                          : ''}
                                      </option>
                                    ))}
                                  </select>
                                  <button
                                    type="button"
                                    onClick={() => removeMeal(index)}
                                    className="inline-flex h-9 w-9 items-center justify-center rounded-lg text-text-muted transition hover:bg-danger/10 hover:text-danger"
                                    aria-label="Hapus makanan"
                                  >
                                    <Trash2 size={16} />
                                  </button>
                                </div>
                              ))}
                            </div>
                          )}
                        </div>
                      )
                    })}
                  </div>
                </div>
              ))}
            </div>
          </section>
        </div>

        <footer className="sticky bottom-0 z-10 flex items-center justify-end gap-3 border-t border-border bg-background/95 px-4 py-4 backdrop-blur sm:px-6">
          <button
            type="button"
            onClick={() => router.push(`/clients/${clientId}/review`)}
            className="rounded-xl border border-border px-4 py-2.5 text-sm font-semibold text-text-secondary transition hover:bg-surface-alt"
          >
            Batal
          </button>
          <SubmitButton />
        </footer>
      </form>
    </div>
  )
}
