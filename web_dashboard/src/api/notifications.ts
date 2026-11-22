import type { NotificationItem } from '../types/api'
import { apiRequest } from './client'

export function getNotifications() {
  return apiRequest<NotificationItem[]>('/users/me/notifications')
}

export function markNotificationRead(notificationId: number) {
  return apiRequest<{ message: string }>(
    `/notifications/${notificationId}/read`,
    { method: 'PATCH' },
  )
}
