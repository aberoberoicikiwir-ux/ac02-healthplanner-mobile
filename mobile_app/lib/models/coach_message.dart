class CoachMessage {
  final int id;
  final String role;
  final String content;
  final String? category;
  final String createdAt;

  const CoachMessage({
    required this.id,
    required this.role,
    required this.content,
    this.category,
    required this.createdAt,
  });

  bool get isUser => role == 'user';
}
