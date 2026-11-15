import 'package:drift/drift.dart' show Value;

import '../../models/coach_message.dart';
import '../local/app_database.dart';
import '../remote/api_service.dart';

class CoachRepository {
  CoachRepository(this._db, this._api);

  final AppDatabase _db;
  final ApiService _api;

  Stream<List<CoachMessage>> watchMessages() {
    return _db.watchCoachMessages().map((rows) => rows.map(_toModel).toList());
  }

  Future<void> refresh() async {
    final data = await _api.getCoachMessages(limit: 50);
    final rows = <CoachMessagesCompanion>[];

    for (final raw in data) {
      final id = (raw['message_id'] as num?)?.toInt();
      if (id == null) continue;
      rows.add(
        CoachMessagesCompanion.insert(
          id: Value(id),
          role: raw['role']?.toString() ?? 'assistant',
          content: raw['content']?.toString() ?? '',
          category: Value(raw['category']?.toString()),
          createdAt: raw['created_at']?.toString() ?? '',
        ),
      );
    }

    await _db.upsertCoachMessages(rows);
  }

  Future<void> send(String message) async {
    final result = await _api.sendCoachMessage(message);
    final userMap = _asMap(result['user_message']);
    final replyMap = _asMap(result['reply']);
    final now = DateTime.now().toUtc().toIso8601String();
    final rows = <CoachMessagesCompanion>[];

    final userId = (userMap['message_id'] as num?)?.toInt();
    if (userId != null) {
      rows.add(
        CoachMessagesCompanion.insert(
          id: Value(userId),
          role: 'user',
          content: userMap['content']?.toString() ?? message,
          createdAt: now,
        ),
      );
    }

    final replyId = (replyMap['message_id'] as num?)?.toInt();
    if (replyId != null) {
      rows.add(
        CoachMessagesCompanion.insert(
          id: Value(replyId),
          role: 'assistant',
          content: replyMap['content']?.toString() ?? '',
          category: Value(result['category']?.toString()),
          createdAt: now,
        ),
      );
    }

    await _db.upsertCoachMessages(rows);
  }

  Future<void> clear() async {
    await _api.clearCoachMessages();
    await _db.clearCoachMessages();
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    return const {};
  }

  CoachMessage _toModel(CoachMessageEntry e) => CoachMessage(
    id: e.id,
    role: e.role,
    content: e.content,
    category: e.category,
    createdAt: e.createdAt,
  );
}
