export type UserRole = 'klien' | 'pt'

export interface AuthUser {
  user_id: number
  name: string
  role: UserRole
}

export interface LoginResponse {
  message: string
  token: string
  user: AuthUser
}

export type Day = 'mon' | 'tue' | 'wed' | 'thu' | 'fri' | 'sat' | 'sun'
export type MealType = 'breakfast' | 'lunch' | 'dinner' | 'snack'
export type AnalysisStatus = 'pending' | 'approved' | 'overridden'

export interface PtClient {
  client_id: number
  status: string
  weight_current: number
  weight_target: number
  name: string
  email: string
}

export interface PaginatedClients {
  data: PtClient[]
  meta: {
    page: number
    limit: number
    total: number
    total_pages: number
  }
}

export interface ClientProfile extends PtClient {
  user_id: number
  assigned_pt_id: number | null
  birth_date: string | null
  gender: 'male' | 'female' | null
  height_cm: number | null
  allergies: string | null
  activity_level: string | null
  created_at?: string
  updated_at?: string
}

export interface ProgressPoint {
  log_date: string
  weight_kg: number | null
  steps: number
}

export interface PlanTargets {
  steps: number
  water_liters: number
  calories: number
}

export interface WorkoutPlanItem {
  day: Day
  exercise_id: number
  sets: number
  reps: number
}

export interface MealPlanItem {
  day: Day
  meal_type: MealType
  food_id: number
}

export interface PlanMeta {
  provider?: string
  model?: string
  attempts?: number
  generated_at?: string
  warnings?: string[]
  allergy_keywords?: string[]
  overridden_by_pt?: boolean
}

export interface PlanOutput {
  feedback: string
  targets: PlanTargets
  workout: WorkoutPlanItem[]
  meals: MealPlanItem[]
  meta?: PlanMeta
}

export interface AiAnalysis {
  analysis_id: number
  client_id: number
  reviewed_by_pt_id: number | null
  week_start_date: string
  ai_output: PlanOutput | string | null
  final_output: PlanOutput | string | null
  status: AnalysisStatus
  reviewed_at: string | null
  created_at: string
}

export interface Exercise {
  exercise_id: number
  name: string
  category: string | null
  calories_per_unit: number | null
}

export interface Food {
  food_id: number
  name: string
  calories: number | null
  protein_g: number | null
  carbs_g: number | null
  fat_g: number | null
}

export interface NotificationItem {
  notification_id: number
  user_id: number
  type: 'ai_insight' | 'reminder' | 'system'
  title: string
  message: string
  is_read: boolean
  created_at: string
}
