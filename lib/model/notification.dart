class NotificationModel {
  final DateTime notificationDate;
  final List<NotificationItems> notificationItems;
  NotificationModel(
      {required this.notificationDate, required this.notificationItems});
}

class NotificationItems {
  String? title, body, recipients, attachment;
  List<String>? status;
  DateTime? timeSent;

  NotificationItems(
      {required this.title,
      required this.body,
      required this.status,
      required this.recipients,
      required this.timeSent,
      this.attachment});
}
