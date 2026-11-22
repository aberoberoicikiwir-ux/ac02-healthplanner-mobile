import { describe, expect, it } from 'vitest'
import type { ClientProfile, Exercise, Food, PlanOutput } from '../types/api'
import {
  clonePlan,
  parsePlanOutput,
  validatePlanDraft,
} from './plan'

const exercises: Exercise[] = [
  {
    exercise_id: 1,
    name: 'Push up',
    category: 'strength',
    calories_per_unit: null,
  },
  {
    exercise_id: 2,
    name: 'Jalan cepat',
    category: 'cardio',
    calories_per_unit: null,
  },
]

const foods: Food[] = [
  {
    food_id: 1,
    name: 'Oatmeal',
    calories: 150,
    protein_g: 5,
    carbs_g: 27,
    fat_g: 3,
  },
  {
    food_id: 2,
    name: 'Kacang rebus',
    calories: 120,
    protein_g: 6,
    carbs_g: 10,
    fat_g: 4,
  },
]

const client: Pick<ClientProfile, 'gender' | 'allergies'> = {
  gender: 'female',
  allergies: 'kacang',
}

function validPlan(): PlanOutput {
  const days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'] as const
  const mealTypes = ['breakfast', 'lunch', 'dinner'] as const

  return {
    feedback:
      'Rencana minggu ini dibuat bertahap agar kamu bisa menjaga konsistensi.',
    targets: { steps: 8000, water_liters: 2, calories: 1700 },
    workout: [{ day: 'mon', exercise_id: 1, sets: 3, reps: 10 }],
    meals: days.flatMap((day) =>
      mealTypes.map((mealType) => ({
        day,
        meal_type: mealType,
        food_id: 1,
      })),
    ),
  }
}

describe('plan utils', () => {
  it('menerima rencana yang valid', () => {
    expect(validatePlanDraft(validPlan(), client, exercises, foods)).toEqual([])
  })

  it('menolak feedback yang terlalu pendek', () => {
    const plan = validPlan()
    plan.feedback = 'Pendek'

    expect(validatePlanDraft(plan, client, exercises, foods)).toContain(
      'Feedback harus 20–600 karakter.',
    )
  })

  it('menolak meal yang belum lengkap', () => {
    const plan = validPlan()
    plan.meals = plan.meals.filter(
      (meal) => !(meal.day === 'mon' && meal.meal_type === 'dinner'),
    )

    expect(
      validatePlanDraft(plan, client, exercises, foods).some((error) =>
        error.includes('Senin / Makan malam'),
      ),
    ).toBe(true)
  })

  it('menolak makanan yang mengandung alergen klien', () => {
    const plan = validPlan()
    plan.meals[0] = { ...plan.meals[0], food_id: 2 }

    expect(
      validatePlanDraft(plan, client, exercises, foods).some((error) =>
        error.includes('mengandung alergen'),
      ),
    ).toBe(true)
  })

  it('menolak cardio dengan sets lebih dari 1', () => {
    const plan = validPlan()
    plan.workout = [{ day: 'mon', exercise_id: 2, sets: 3, reps: 30 }]

    expect(
      validatePlanDraft(plan, client, exercises, foods).some((error) =>
        error.includes('sets=1'),
      ),
    ).toBe(true)
  })

  it('mengurai plan dari string JSON dan mengembalikan null untuk teks rusak', () => {
    expect(parsePlanOutput(JSON.stringify(validPlan()))?.targets.steps).toBe(
      8000,
    )
    expect(parsePlanOutput('bukan json')).toBeNull()
  })

  it('clonePlan tidak mengubah plan asli', () => {
    const original = validPlan()
    const copy = clonePlan(original)
    copy.targets.steps = 1000
    copy.workout[0].sets = 1

    expect(original.targets.steps).toBe(8000)
    expect(original.workout[0].sets).toBe(3)
  })
})
