import type { Exercise, Food } from '../types/api'
import { apiRequest } from './client'

export function getExercises() {
  return apiRequest<Exercise[]>('/exercises')
}

export function getFoods() {
  return apiRequest<Food[]>('/foods')
}
