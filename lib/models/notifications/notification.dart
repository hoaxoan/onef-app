import 'package:dcache/dcache.dart';
import 'package:meta/meta.dart';
import 'package:onef/models/updatable_model.dart';
import 'package:onef/models/user.dart';
import 'package:timeago/timeago.dart' as timeago;

class OFNotification extends UpdatableModel<OFNotification> {
  final int id;
  User owner;
  NotificationType type;
  dynamic contentObject;
  DateTime created;

  bool read;

  OFNotification(
      {this.id,
      this.owner,
      this.type,
      this.contentObject,
      this.created,
      this.read});

  static final factory = NotificationFactory();

  factory OFNotification.fromJSON(Map<String, dynamic> json) {
    return factory.fromJson(json);
  }

  String getRelativeCreated() {
    return timeago.format(created);
  }

  @override
  void updateFromJson(Map json) {
    if (json.containsKey('owner')) {
      owner = factory.parseUser(json['owner']);
    }

    if (json.containsKey('notification_type')) {
      type = NotificationType.parse(json['notification_type']);
    }

    if (json.containsKey('content_object')) {
      contentObject = factory.parseContentObject(
          contentObjectData: json['content_object'], type: type);
    }

    if (json.containsKey('read')) {
      read = json['read'];
    }

    if (json.containsKey('created')) {
      created = factory.parseCreated(json['created']);
    }
  }

  void markNotificationAsRead() {
    read = true;
    notifyUpdate();
  }
}

class NotificationFactory extends UpdatableModelFactory<OFNotification> {
  @override
  SimpleCache<int, OFNotification> cache =
      SimpleCache(storage: UpdatableModelSimpleStorage(size: 120));

  @override
  OFNotification makeFromJson(Map json) {
    NotificationType type = NotificationType.parse(json['notification_type']);

    return OFNotification(
        id: json['id'],
        owner: parseUser(json['owner']),
        type: type,
        contentObject: parseContentObject(
            contentObjectData: json['content_object'], type: type),
        created: parseCreated(json['created']),
        read: json['read']);
  }

  User parseUser(Map userData) {
    if (userData == null) return null;
    return User.fromJson(userData);
  }

  dynamic parseContentObject(
      {@required Map contentObjectData, @required NotificationType type}) {
    if (contentObjectData == null) return null;

    dynamic contentObject;
    switch (type) {
      default:
    }
    return contentObject;
  }

  DateTime parseCreated(String created) {
    return DateTime.parse(created).toLocal();
  }
}

class NotificationType {
  // Using a custom-built enum class to link the notification type strings
  // directly to the matching enum constants.
  // This class can still be used in switch statements as a normal enum.
  final String code;

  const NotificationType._internal(this.code);

  toString() => code;

  static const postReaction = const NotificationType._internal('PR');
  static const postComment = const NotificationType._internal('PC');
  static const postCommentReply = const NotificationType._internal('PCR');
  static const postCommentReaction = const NotificationType._internal('PCRA');
  static const connectionRequest = const NotificationType._internal('CR');
  static const connectionConfirmed = const NotificationType._internal('CC');
  static const follow = const NotificationType._internal('F');
  static const communityInvite = const NotificationType._internal('CI');
  static const postCommentUserMention =
      const NotificationType._internal('PCUM');
  static const postUserMention = const NotificationType._internal('PUM');
  static const communityNewPost = const NotificationType._internal('CNP');
  static const userNewPost = const NotificationType._internal('UNP');

  static const _values = const <NotificationType>[
    postReaction,
    postComment,
    postCommentReply,
    postCommentReaction,
    connectionRequest,
    connectionConfirmed,
    follow,
    communityInvite,
    postCommentUserMention,
    postUserMention,
    communityNewPost,
    userNewPost
  ];

  static values() => _values;

  static NotificationType parse(String string) {
    if (string == null) return null;

    NotificationType notificationType;
    for (var type in _values) {
      if (string == type.code) {
        notificationType = type;
        break;
      }
    }

    if (notificationType == null) {
      // Don't throw as we might introduce new notifications on the API which might not be yet in code
      print('Unsupported notification type');
    }

    return notificationType;
  }
}
