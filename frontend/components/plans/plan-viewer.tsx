import { AlertTriangle, Apple, Dumbbell, Info, Target } from 'lucide-react'
import {
  DAY_LABELS,
  MEAL_LABELS,
  formatWorkoutDetail,
  getExercise,
  getFood,
  groupMealsByDay,
  groupWorkoutByDay,
} from '@/lib/plan'
import type { Exercise, Food, PlanOutput } from '@/types/api'

export function PlanViewer({
  plan,
  exercises,
  foods,
}: {
  plan: PlanOutput
  exercises: Exercise[]
  foods: Food[]
}) {
  const workoutByDay = groupWorkoutByDay(plan.workout)
  const mealsByDay = groupMealsByDay(plan.meals)
  const warnings = plan.meta?.warnings ?? []

  return (
    <div className="space-y-4">
      <section className="panel p-5">
        <div className="flex items-center gap-3">
          <div className="rounded-xl bg-primary/15 p-2.5 text-accent">
            <Info size={18} />
          </div>
          <div>
            <h3 className="font-semibold">Feedback untuk klien</h3>
            <p className="text-xs text-text-muted">
              Pesan yang akan diterima klien setelah rencana disetujui.
            </p>
          </div>
        </div>
        <p className="mt-4 whitespace-pre-line text-sm leading-7 text-text-secondary">
          {plan.feedback}
        </p>
      </section>

      <section className="grid gap-3 sm:grid-cols-3">
        <div className="panel p-4">
          <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-[0.16em] text-text-muted">
            <Target size={14} className="text-accent" />
            Langkah
          </div>
          <p className="mt-2 text-2xl font-semibold">
            {plan.targets.steps.toLocaleString('id-ID')}
          </p>
        </div>
        <div className="panel p-4">
          <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-[0.16em] text-text-muted">
            <Target size={14} className="text-accent" />
            Air
          </div>
          <p className="mt-2 text-2xl font-semibold">
            {plan.targets.water_liters} L
          </p>
        </div>
        <div className="panel p-4">
          <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-[0.16em] text-text-muted">
            <Target size={14} className="text-accent" />
            Kalori
          </div>
          <p className="mt-2 text-2xl font-semibold">
            {plan.targets.calories.toLocaleString('id-ID')}
          </p>
        </div>
      </section>

      {warnings.length > 0 && (
        <section className="rounded-2xl border border-warning/25 bg-warning/10 p-4">
          <div className="flex items-center gap-2 text-sm font-semibold text-warning">
            <AlertTriangle size={16} />
            Peringatan kualitas rencana
          </div>
          <ul className="mt-2 space-y-1 text-sm leading-6 text-warning/90">
            {warnings.map((warning) => (
              <li key={warning}>• {warning}</li>
            ))}
          </ul>
        </section>
      )}

      <section className="grid gap-4 xl:grid-cols-2">
        {workoutByDay.map((day) => (
          <div key={day.day} className="panel p-5">
            <div className="flex items-center gap-2">
              <Dumbbell size={16} className="text-accent" />
              <h3 className="font-semibold">{DAY_LABELS[day.day]}</h3>
            </div>

            {day.items.length === 0 ? (
              <p className="mt-3 text-sm text-text-muted">
                Hari istirahat / belum ada latihan.
              </p>
            ) : (
              <ul className="mt-3 space-y-2">
                {day.items.map((item, index) => {
                  const exercise = getExercise(item.exercise_id, exercises)

                  return (
                    <li
                      key={`${day.day}-${item.exercise_id}-${index}`}
                      className="flex items-start justify-between gap-3 rounded-xl bg-surface-alt/60 px-3 py-2.5"
                    >
                      <div>
                        <p className="text-sm font-medium">
                          {exercise?.name ?? `Latihan #${item.exercise_id}`}
                        </p>
                        <p className="text-xs text-text-muted">
                          {exercise?.category ?? 'Latihan'}
                        </p>
                      </div>
                      <span className="shrink-0 text-xs font-semibold text-accent">
                        {formatWorkoutDetail(item, exercise)}
                      </span>
                    </li>
                  )
                })}
              </ul>
            )}
          </div>
        ))}
      </section>

      <section className="grid gap-4 xl:grid-cols-2">
        {mealsByDay.map((day) => (
          <div key={day.day} className="panel p-5">
            <div className="flex items-center gap-2">
              <Apple size={16} className="text-success" />
              <h3 className="font-semibold">{DAY_LABELS[day.day]}</h3>
            </div>

            {day.items.length === 0 ? (
              <p className="mt-3 text-sm text-text-muted">
                Belum ada menu untuk hari ini.
              </p>
            ) : (
              <ul className="mt-3 space-y-2">
                {day.items.map((item, index) => {
                  const food = getFood(item.food_id, foods)

                  return (
                    <li
                      key={`${day.day}-${item.meal_type}-${item.food_id}-${index}`}
                      className="rounded-xl bg-surface-alt/60 px-3 py-2.5"
                    >
                      <p className="text-xs font-semibold uppercase tracking-[0.14em] text-text-muted">
                        {MEAL_LABELS[item.meal_type]}
                      </p>
                      <div className="mt-1 flex items-start justify-between gap-3">
                        <p className="text-sm font-medium">
                          {food?.name ?? `Makanan #${item.food_id}`}
                        </p>
                        {food?.calories != null && (
                          <span className="shrink-0 text-xs text-text-muted">
                            {food.calories} kkal
                          </span>
                        )}
                      </div>
                    </li>
                  )
                })}
              </ul>
            )}
          </div>
        ))}
      </section>

      {plan.meta && (
        <p className="text-xs text-text-muted">
          Provider: {plan.meta.provider ?? '—'} · Model:{' '}
          {plan.meta.model ?? '—'} · Percobaan: {plan.meta.attempts ?? '—'}
        </p>
      )}
    </div>
  )
}
