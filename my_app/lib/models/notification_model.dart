class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });
}
