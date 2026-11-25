'use server'

import { revalidatePath } from 'next/cache'
import {
  getNotifications,
  markNotificationRead,
} from '@/lib/pt'
import { requireSession } from '@/lib/session'

export async function markReadAction(formData: FormData) {
  const session = await requireSession()
  const notificationId = Number(formData.get('notificationId'))

  if (Number.isInteger(notificationId) && notificationId > 0) {
    await markNotificationRead(notificationId, session.token)
  }

  revalidatePath('/notifications')
  revalidatePath('/')
}

export async function markAllReadAction() {
  const session = await requireSession()
  const notifications = await getNotifications(session.token)
  const unread = notifications.filter((item) => !item.is_read)

  await Promise.all(
    unread.map((item) => markNotificationRead(item.notification_id, session.token)),
  )

  revalidatePath('/notifications')
  revalidatePath('/')
}
