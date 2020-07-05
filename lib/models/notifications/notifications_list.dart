import 'package:onef/models/notifications/notification.dart';

class NotificationsList {
  final List<OFNotification> notifications;

  NotificationsList({
    this.notifications,
  });

  factory NotificationsList.fromJson(List<dynamic> parsedJson) {
    List<OFNotification> notifications = parsedJson
        .map((notificationJson) => OFNotification.fromJSON(notificationJson))
        .toList();

    return new NotificationsList(
      notifications: notifications,
    );
  }
}
