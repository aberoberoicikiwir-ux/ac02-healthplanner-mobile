class InsightNotification {
  final int id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String createdAt;

  const InsightNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  bool get isAiInsight => type == 'ai_insight';
}
