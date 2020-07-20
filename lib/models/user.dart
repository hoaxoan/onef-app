import 'package:dcache/dcache.dart';
import 'package:onef/models/badge.dart';
import 'package:onef/models/circles_list.dart';
import 'package:onef/models/community.dart';
import 'package:onef/models/community_invite_list.dart';
import 'package:onef/models/community_membership.dart';
import 'package:onef/models/community_membership_list.dart';
import 'package:onef/models/follows_lists_list.dart';
import 'package:onef/models/language.dart';
import 'package:onef/models/post.dart';
import 'package:onef/models/post_comment.dart';
import 'package:onef/models/updatable_model.dart';
import 'package:onef/models/user_notifications_settings.dart';
import 'package:onef/models/user_profile.dart';

class User extends UpdatableModel<User> {
  int id;
  String uuid;
  int connectionsCircleId;
  String email;
  String username;
  Language language;
  UserProfile profile;
  DateTime dateJoined;
  UserNotificationsSettings notificationsSettings;
  int followersCount;
  int followingCount;
  int unreadNotificationsCount;
  int postsCount;
  int inviteCount;
  int pendingCommunitiesModeratedObjectsCount;
  int activeModerationPenaltiesCount;
  bool areGuidelinesAccepted;
  bool areNewPostNotificationsEnabled;
  bool isFollowing;
  bool isFollowed;
  bool isConnected;
  bool isReported;
  bool isBlocked;
  bool isGlobalModerator;
  bool isFullyConnected;
  bool isPendingConnectionConfirmation;
  bool isMemberOfCommunities;

  CirclesList connectedCircles;
  FollowsListsList followLists;
  CommunityMembershipList communitiesMemberships;
  CommunityInviteList communitiesInvites;

  static final navigationUsersFactory = UserFactory(
      cache:
          LfuCache<int, User>(storage: UpdatableModelSimpleStorage(size: 100)));
  static final sessionUsersFactory = UserFactory(
      cache: SimpleCache<int, User>(
          storage: UpdatableModelSimpleStorage(size: 10)));

  factory User.fromJson(Map<String, dynamic> json,
      {bool storeInSessionCache = false}) {
    if (json == null) return null;

    int userId = json['id'];

    User user = navigationUsersFactory.getItemWithIdFromCache(userId) ??
        sessionUsersFactory.getItemWithIdFromCache(userId);
    if (user != null) {
      user.update(json);
      return user;
    }
    return storeInSessionCache
        ? sessionUsersFactory.fromJson(json)
        : navigationUsersFactory.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'date_joined': dateJoined?.toString(),
      'connections_circle_id': connectionsCircleId,
      'email': email,
      'username': username,
      'language': language?.toJson(),
      'profile': profile?.toJson(),
      'notifications_settings': notificationsSettings?.toJson(),
      'followers_count': followersCount,
      'following_count': followingCount,
      'unread_notifications_count': unreadNotificationsCount,
      'posts_count': postsCount,
      'invite_count': inviteCount,
      'pending_communities_moderated_objects_count':
          pendingCommunitiesModeratedObjectsCount,
      'active_moderation_penalties_count': activeModerationPenaltiesCount,
      'are_guidelines_accepted': areGuidelinesAccepted,
      'are_new_post_notifications_enabled': areNewPostNotificationsEnabled,
      'is_following': isFollowing,
      'is_followed': isFollowed,
      'is_connected': isConnected,
      'is_reported': isReported,
      'is_blocked': isBlocked,
      'is_global_moderator': isGlobalModerator,
      'is_fully_connected': isFullyConnected,
      'is_pending_connection_confirmation': isPendingConnectionConfirmation,
      'is_member_of_communities': isMemberOfCommunities,
    };
  }

  static void clearNavigationCache() {
    navigationUsersFactory.clearCache();
  }

  static void clearSessionCache() {
    sessionUsersFactory.clearCache();
  }

  User(
      {this.id,
      this.uuid,
      this.dateJoined,
      this.connectionsCircleId,
      this.username,
      this.email,
      this.profile,
      this.language,
      this.notificationsSettings,
      this.followersCount,
      this.followingCount,
      this.unreadNotificationsCount,
      this.postsCount,
      this.inviteCount,
      this.areNewPostNotificationsEnabled,
      this.isFollowing,
      this.isFollowed,
      this.isBlocked,
      this.isGlobalModerator,
      this.isConnected,
      this.isReported,
      this.isFullyConnected,
      this.isMemberOfCommunities,
      this.activeModerationPenaltiesCount,
      this.pendingCommunitiesModeratedObjectsCount,
      this.areGuidelinesAccepted});

  void updateFromJson(Map json) {
    if (json.containsKey('username')) username = json['username'];
    if (json.containsKey('uuid')) uuid = json['uuid'];
    if (json.containsKey('date_joined'))
      dateJoined = navigationUsersFactory.parseDateJoined(json['date_joined']);
    if (json.containsKey('are_guidelines_accepted'))
      areGuidelinesAccepted = json['are_guidelines_accepted'];
    if (json.containsKey('email')) email = json['email'];
    if (json.containsKey('profile')) {
      if (profile != null) {
        profile.updateFromJson(json['profile']);
      } else {
        profile = navigationUsersFactory.parseUserProfile(json['profile']);
      }
    }
    if (json.containsKey('language')) {
      language = navigationUsersFactory.parseLanguage(json['language']);
    }
    if (json.containsKey('notifications_settings')) {
      if (notificationsSettings != null) {
        notificationsSettings.updateFromJson(json['notifications_settings']);
      } else {
        notificationsSettings = navigationUsersFactory
            .parseUserNotificationsSettings(json['notifications_settings']);
      }
    }
    if (json.containsKey('followers_count'))
      followersCount = json['followers_count'];
    if (json.containsKey('pending_communities_moderated_objects_count'))
      pendingCommunitiesModeratedObjectsCount =
          json['pending_communities_moderated_objects_count'];
    if (json.containsKey('active_moderation_penalties_count'))
      activeModerationPenaltiesCount =
          json['active_moderation_penalties_count'];
    if (json.containsKey('following_count'))
      followingCount = json['following_count'];
    if (json.containsKey('unread_notifications_count'))
      unreadNotificationsCount = json['unread_notifications_count'];
    if (json.containsKey('posts_count')) postsCount = json['posts_count'];
    if (json.containsKey('invite_count')) inviteCount = json['invite_count'];
    if (json.containsKey('are_new_post_notifications_enabled'))
      areNewPostNotificationsEnabled =
          json['are_new_post_notifications_enabled'];
    if (json.containsKey('is_following')) isFollowing = json['is_following'];
    if (json.containsKey('is_followed')) isFollowed = json['is_followed'];
    if (json.containsKey('is_connected')) isConnected = json['is_connected'];
    if (json.containsKey('is_global_moderator'))
      isGlobalModerator = json['is_global_moderator'];
    if (json.containsKey('is_blocked')) isBlocked = json['is_blocked'];
    if (json.containsKey('is_reported')) isReported = json['is_reported'];
    if (json.containsKey('connections_circle_id'))
      connectionsCircleId = json['connections_circle_id'];
    if (json.containsKey('is_fully_connected'))
      isFullyConnected = json['is_fully_connected'];
    if (json.containsKey('is_pending_connection_confirmation'))
      isPendingConnectionConfirmation =
          json['is_pending_connection_confirmation'];
  }

  String getEmail() {
    return this.email;
  }

  bool hasProfileLocation() {
    return profile.hasLocation();
  }

  bool hasProfileUrl() {
    return profile.hasUrl();
  }

  bool hasAge() {
    return dateJoined != null;
  }

  bool hasProfileAvatar() {
    return this.profile.avatar != null;
  }

  bool hasProfileCover() {
    return this.profile.cover != null;
  }

  String getProfileAvatar() {
    return this.profile?.avatar;
  }

  String getProfileName() {
    return this.profile.name;
  }

  String getProfileCover() {
    return this.profile.cover;
  }

  String getProfileBio() {
    return this.profile.bio;
  }

  String getProfileUrl() {
    return this.profile.url;
  }

  String getProfileLocation() {
    return this.profile.location;
  }

  bool hasProfileBadges() {
    return this.profile != null &&
        this.profile.badges != null &&
        this.profile.badges.length > 0;
  }

  bool hasLanguage() {
    return this.language != null;
  }

  bool hasUnreadNotifications() {
    return unreadNotificationsCount != null && unreadNotificationsCount > 0;
  }

  void resetUnreadNotificationsCount() {
    this.unreadNotificationsCount = 0;
    notifyUpdate();
  }

  void incrementUnreadNotificationsCount() {
    if (this.unreadNotificationsCount != null) {
      this.unreadNotificationsCount += 1;
      notifyUpdate();
    }
  }

  void incrementFollowersCount() {
    if (this.followersCount != null) {
      this.followersCount += 1;
      notifyUpdate();
    }
  }

  void decrementFollowersCount() {
    if (this.followersCount != null && this.followersCount > 0) {
      this.followersCount -= 1;
      notifyUpdate();
    }
  }

  bool hasPendingCommunitiesModeratedObjects() {
    return pendingCommunitiesModeratedObjectsCount != null &&
        pendingCommunitiesModeratedObjectsCount > 0;
  }

  bool hasActiveModerationPenaltiesCount() {
    return activeModerationPenaltiesCount != null &&
        activeModerationPenaltiesCount > 0;
  }

  void setIsReported(isReported) {
    this.isReported = isReported;
    notifyUpdate();
  }

  bool canBlockOrUnblockUser(User user) {
    return user.id != id;
  }

  bool canDisableOrEnableCommentsForPost(Post post) {
    User loggedInUser = this;
    bool _canDisableOrEnableComments = true;

    if (post.hasCommunity()) {
      Community postCommunity = post.community;

      if (postCommunity.isAdministrator(loggedInUser) ||
          postCommunity.isModerator(loggedInUser)) {
        _canDisableOrEnableComments = true;
      }
    }
    return _canDisableOrEnableComments;
  }

  bool canTranslatePostComment(PostComment postComment, Post post) {
    if ((!post.hasCommunity() && post.isEncircledPost()) ||
        language?.code == null) return false;

    return postComment.hasLanguage() &&
        postComment.getLanguage().code != language.code;
  }

  bool canTranslatePost(Post post) {
    if ((!post.hasCommunity() && post.isEncircledPost()) ||
        language?.code == null) return false;

    return post.hasLanguage() && post.getLanguage().code != language.code;
  }

  bool canReplyPostComment(PostComment postComment) {
    return postComment.parentComment == null;
  }

  bool isAdministratorOfCommunity(Community community) {
    CommunityMembership membership = getMembershipForCommunity(community);
    if (membership == null) return false;
    return membership.isAdministrator;
  }

  bool isModeratorOfCommunity(Community community) {
    CommunityMembership membership = getMembershipForCommunity(community);
    if (membership == null) return false;
    return membership.isModerator;
  }

  bool isMemberOfCommunity(Community community) {
    return getMembershipForCommunity(community) != null;
  }

  CommunityMembership getMembershipForCommunity(Community community) {
    if (communitiesMemberships == null) return null;

    int membershipIndex = communitiesMemberships.communityMemberships
        .indexWhere((CommunityMembership communityMembership) {
      return communityMembership.userId == this.id &&
          communityMembership.communityId == community.id;
    });

    if (membershipIndex < 0) return null;

    return communitiesMemberships.communityMemberships[membershipIndex];
  }

  List<Badge> getProfileBadges() {
    return this.profile.badges;
  }

  Badge getDisplayedProfileBadge() {
    return getProfileBadges().first;
  }

}

class UserFactory extends UpdatableModelFactory<User> {
  UserFactory({cache}) : super(cache: cache);

  @override
  User makeFromJson(Map json) {
    return User(
        id: json['id'],
        uuid: json['uuid'],
        dateJoined: parseDateJoined(json['date_joined']),
        areGuidelinesAccepted: json['are_guidelines_accepted'],
        connectionsCircleId: json['connections_circle_id'],
        followersCount: json['followers_count'],
        postsCount: json['posts_count'],
        inviteCount: json['invite_count'],
        unreadNotificationsCount: json['unread_notifications_count'],
        pendingCommunitiesModeratedObjectsCount:
            json['pending_communities_moderated_objects_count'],
        activeModerationPenaltiesCount:
            json['active_moderation_penalties_count'],
        email: json['email'],
        username: json['username'],
        language: parseLanguage(json['language']),
        followingCount: json['following_count'],
        isFollowing: json['is_following'],
        isFollowed: json['is_followed'],
        areNewPostNotificationsEnabled:
            json['are_new_post_notifications_enabled'],
        isConnected: json['is_connected'],
        isGlobalModerator: json['is_global_moderator'],
        isBlocked: json['is_blocked'],
        isReported: json['is_reported'],
        isFullyConnected: json['is_fully_connected']);
  }

  UserProfile parseUserProfile(Map profile) {
    if (profile == null) return null;
    return UserProfile.fromJSON(profile);
  }

  UserNotificationsSettings parseUserNotificationsSettings(
      Map notificationsSettings) {
    if (notificationsSettings == null) return null;
    return UserNotificationsSettings.fromJSON(notificationsSettings);
  }

  Language parseLanguage(Map languageData) {
    if (languageData == null) return null;
    return Language.fromJson(languageData);
  }

  DateTime parseDateJoined(String dateJoined) {
    if (dateJoined == null) return null;
    return DateTime.parse(dateJoined).toLocal();
  }
}
