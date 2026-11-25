import type {
  AiAnalysis,
  ClientProfile,
  Day,
  Exercise,
  Food,
  MealPlanItem,
  MealType,
  PlanOutput,
  WorkoutPlanItem,
} from '@/types/api'

export const DAYS: Day[] = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']
export const MEAL_TYPES: MealType[] = ['breakfast', 'lunch', 'dinner', 'snack']
export const REQUIRED_MEALS: MealType[] = ['breakfast', 'lunch', 'dinner']
export const TIMED_CATEGORIES = ['cardio', 'flexibility']

export const DAY_LABELS: Record<Day, string> = {
  mon: 'Senin',
  tue: 'Selasa',
  wed: 'Rabu',
  thu: 'Kamis',
  fri: 'Jumat',
  sat: 'Sabtu',
  sun: 'Minggu',
}

export const MEAL_LABELS: Record<MealType, string> = {
  breakfast: 'Sarapan',
  lunch: 'Makan siang',
  dinner: 'Makan malam',
  snack: 'Camilan',
}

export function parsePlanOutput(
  value: PlanOutput | string | null | undefined,
): PlanOutput | null {
  if (!value) return null

  if (typeof value === 'string') {
    try {
      const parsed = JSON.parse(value) as PlanOutput
      return parsed && typeof parsed === 'object' ? parsed : null
    } catch {
      return null
    }
  }

  return value
}

export function getPlanFromAnalysis(analysis: AiAnalysis): PlanOutput | null {
  return parsePlanOutput(analysis.final_output ?? analysis.ai_output)
}

export function clonePlan(plan: PlanOutput): PlanOutput {
  return {
    feedback: plan.feedback,
    targets: { ...plan.targets },
    workout: plan.workout.map((item) => ({ ...item })),
    meals: plan.meals.map((item) => ({ ...item })),
    meta: plan.meta
      ? {
          ...plan.meta,
          warnings: [...(plan.meta.warnings ?? [])],
        }
      : undefined,
  }
}

export function isTimedCategory(category: string | null | undefined): boolean {
  return TIMED_CATEGORIES.includes((category ?? '').toLowerCase())
}

export function getExercise(exerciseId: number, exercises: Exercise[]) {
  return exercises.find((exercise) => exercise.exercise_id === exerciseId)
}

export function getFood(foodId: number, foods: Food[]) {
  return foods.find((food) => food.food_id === foodId)
}

export function formatWorkoutDetail(
  item: WorkoutPlanItem,
  exercise: Exercise | undefined,
): string {
  if (isTimedCategory(exercise?.category)) {
    return `${item.reps} menit`
  }

  return `${item.sets} set × ${item.reps} reps`
}

export function getMinCalories(gender: ClientProfile['gender']): number {
  if (gender === 'female') return 1200
  if (gender === 'male') return 1500
  return 1500
}

function parseAllergyTerms(allergies: string | null): string[] {
  return (allergies ?? '')
    .toLowerCase()
    .split(/[,;]/)
    .map((term) => term.trim())
    .filter((term) => term.length > 1)
}

function findAllergenHits(foodName: string, terms: string[]): string[] {
  const normalizedName = foodName.toLowerCase()
  return terms.filter((term) => normalizedName.includes(term))
}

export function validatePlanDraft(
  plan: PlanOutput,
  client: Pick<ClientProfile, 'gender' | 'allergies'>,
  exercises: Exercise[],
  foods: Food[],
): string[] {
  const errors: string[] = []
  const feedback = plan.feedback.trim()

  if (feedback.length < 20 || feedback.length > 600) {
    errors.push('Feedback harus 20–600 karakter.')
  }

  const { steps, water_liters: water, calories } = plan.targets
  const minCalories = getMinCalories(client.gender)

  if (!Number.isInteger(steps) || steps < 1000 || steps > 30000) {
    errors.push('Target langkah harus bilangan bulat 1.000–30.000.')
  }

  if (!Number.isFinite(water) || water < 0.5 || water > 6) {
    errors.push('Target air harus 0,5–6 liter.')
  }

  if (
    !Number.isInteger(calories) ||
    calories < minCalories ||
    calories > 4500
  ) {
    errors.push(
      `Target kalori harus bilangan bulat ${minCalories.toLocaleString(
        'id-ID',
      )}–4.500.`,
    )
  }

  if (plan.workout.length < 1 || plan.workout.length > 28) {
    errors.push('Workout harus berisi 1–28 item.')
  }

  const workoutPerDay: Record<string, number> = {}
  const workoutSeen = new Set<string>()

  plan.workout.forEach((item, index) => {
    const exercise = getExercise(item.exercise_id, exercises)

    if (!exercise) {
      errors.push(`Workout #${index + 1}: latihan tidak ditemukan.`)
      return
    }

    const key = `${item.day}:${item.exercise_id}`
    if (workoutSeen.has(key)) {
      errors.push(
        `Workout #${index + 1}: "${exercise.name}" dobel di hari ${
          DAY_LABELS[item.day]
        }.`,
      )
    }
    workoutSeen.add(key)
    workoutPerDay[item.day] = (workoutPerDay[item.day] ?? 0) + 1

    if (isTimedCategory(exercise.category)) {
      if (item.sets !== 1 || !Number.isInteger(item.reps) || item.reps < 5 || item.reps > 90) {
        errors.push(
          `Workout #${index + 1}: "${exercise.name}" harus sets=1 dan durasi 5–90 menit.`,
        )
      }
    } else if (
      !Number.isInteger(item.sets) ||
      item.sets < 1 ||
      item.sets > 6 ||
      !Number.isInteger(item.reps) ||
      item.reps < 1 ||
      item.reps > 30
    ) {
      errors.push(
        `Workout #${index + 1}: "${exercise.name}" harus sets 1–6 dan reps 1–30.`,
      )
    }
  })

  for (const [day, count] of Object.entries(workoutPerDay)) {
    if (count > 4) {
      errors.push(`Hari ${DAY_LABELS[day as Day]} punya lebih dari 4 latihan.`)
    }
  }

  if (Object.keys(workoutPerDay).length > 6) {
    errors.push('Workout maksimal 6 hari; minimal 1 hari istirahat.')
  }

  if (plan.meals.length < 1 || plan.meals.length > 84) {
    errors.push('Meal harus berisi 1–84 item.')
  }

  const mealPerSlot: Record<string, number> = {}
  const mealSeen = new Set<string>()
  const allergyTerms = parseAllergyTerms(client.allergies)

  plan.meals.forEach((item, index) => {
    const food = getFood(item.food_id, foods)

    if (!food) {
      errors.push(`Meal #${index + 1}: makanan tidak ditemukan.`)
      return
    }

    const key = `${item.day}:${item.meal_type}:${item.food_id}`
    if (mealSeen.has(key)) {
      errors.push(
        `Meal #${index + 1}: "${food.name}" dobel di ${
          DAY_LABELS[item.day]
        }/${MEAL_LABELS[item.meal_type]}.`,
      )
    }
    mealSeen.add(key)

    const slot = `${item.day}:${item.meal_type}`
    mealPerSlot[slot] = (mealPerSlot[slot] ?? 0) + 1

    const hits = findAllergenHits(food.name, allergyTerms)
    if (hits.length > 0) {
      errors.push(
        `Meal #${index + 1}: "${food.name}" mengandung alergen klien (${hits.join(
          ', ',
        )}).`,
      )
    }
  })

  for (const [slot, count] of Object.entries(mealPerSlot)) {
    if (count > 4) {
      const [day, mealType] = slot.split(':')
      errors.push(
        `${DAY_LABELS[day as Day]}/${MEAL_LABELS[mealType as MealType]} punya lebih dari 4 makanan.`,
      )
    }
  }

  for (const day of DAYS) {
    for (const mealType of REQUIRED_MEALS) {
      if (!mealPerSlot[`${day}:${mealType}`]) {
        errors.push(
          `Meal belum lengkap: ${DAY_LABELS[day]} / ${MEAL_LABELS[mealType]}.`,
        )
      }
    }
  }

  return errors
}

export function groupWorkoutByDay(items: WorkoutPlanItem[]) {
  return DAYS.map((day) => ({
    day,
    items: items.filter((item) => item.day === day),
  }))
}

export function groupMealsByDay(items: MealPlanItem[]) {
  return DAYS.map((day) => ({
    day,
    items: items.filter((item) => item.day === day),
  }))
}
