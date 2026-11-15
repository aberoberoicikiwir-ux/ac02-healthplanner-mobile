import 'package:drift/drift.dart' show Value;

import '../../models/insight_notification.dart';
import '../local/app_database.dart';
import '../remote/api_service.dart';

class InsightRepository {
  InsightRepository(this._db, this._api);

  final AppDatabase _db;
  final ApiService _api;

  Stream<List<InsightNotification>> watchNotifications() {
    return _db.watchNotifications().map((rows) => rows.map(_toModel).toList());
  }

  Future<void> refresh() async {
    final data = await _api.getNotifications();
    final rows = <NotificationEntriesCompanion>[];
    final ids = <int>{};

    for (final raw in data) {
      final id = (raw['notification_id'] as num?)?.toInt();
      if (id == null) continue;
      ids.add(id);
      rows.add(
        NotificationEntriesCompanion.insert(
          id: Value(id),
          type: raw['type']?.toString() ?? 'system',
          title: raw['title']?.toString() ?? '',
          message: raw['message']?.toString() ?? '',
          isRead: Value(raw['is_read'] == true),
          createdAt: raw['created_at']?.toString() ?? '',
        ),
      );
    }

    await _db.upsertNotifications(rows);
    await _db.deleteStaleNotifications(ids);
  }

  Future<void> markRead(int id) async {
    await _api.markNotificationRead(id);
    await _db.markNotificationReadLocal(id);
  }

  InsightNotification _toModel(NotificationEntry e) => InsightNotification(
    id: e.id,
    type: e.type,
    title: e.title,
    message: e.message,
    isRead: e.isRead,
    createdAt: e.createdAt,
  );
}
