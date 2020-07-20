import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:crypto/crypto.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:meta/meta.dart';
import 'package:onef/models/categories_list.dart';
import 'package:onef/models/circle.dart';
import 'package:onef/models/circles_list.dart';
import 'package:onef/models/community.dart';
import 'package:onef/models/emoji.dart';
import 'package:onef/models/emoji_group_list.dart';
import 'package:onef/models/follows_list.dart';
import 'package:onef/models/post.dart';
import 'package:onef/models/post_comment.dart';
import 'package:onef/models/post_comment_list.dart';
import 'package:onef/models/post_comment_reaction.dart';
import 'package:onef/models/post_comment_reaction_list.dart';
import 'package:onef/models/post_media_list.dart';
import 'package:onef/models/post_reaction.dart';
import 'package:onef/models/posts_list.dart';
import 'package:onef/models/story_categories_list.dart';
import 'package:onef/models/story_category.dart';
import 'package:onef/models/color_range.dart';
import 'package:onef/models/device.dart';
import 'package:onef/models/devices_list.dart';
import 'package:onef/models/hashtags_list.dart';
import 'package:onef/models/language.dart';
import 'package:onef/models/language_list.dart';
import 'package:onef/models/mood.dart';
import 'package:onef/models/moods_list.dart';
import 'package:onef/models/note.dart';
import 'package:onef/models/notes_list.dart';
import 'package:onef/models/notifications/notification.dart';
import 'package:onef/models/notifications/notifications_list.dart';
import 'package:onef/models/task.dart';
import 'package:onef/models/task_home.dart';
import 'package:onef/models/task_home_list.dart';
import 'package:onef/models/task_list.dart';
import 'package:onef/models/task_widget.dart';
import 'package:onef/models/tasks_list.dart';
import 'package:onef/models/user.dart';
import 'package:onef/models/user_notifications_settings.dart';
import 'package:onef/models/users_list.dart';
import 'package:onef/pages/auth/create_account/blocs/create_account.dart';
import 'package:onef/services/auth_api.dart';
import 'package:onef/services/categories_api.dart';
import 'package:onef/services/color_ranges_api.dart';
import 'package:onef/services/connections_api.dart';
import 'package:onef/services/connections_circles_api.dart';
import 'package:onef/services/devices_api.dart';
import 'package:onef/services/draft.dart';
import 'package:onef/services/hashtags_api.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/moods_api.dart';
import 'package:onef/services/notes_api.dart';
import 'package:onef/services/notifications_api.dart';
import 'package:onef/services/posts_api.dart';
import 'package:onef/services/push_notifications.dart';
import 'package:onef/services/storage.dart';
import 'package:onef/services/stories_api.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

import 'intercom.dart';

class UserService {
  OFStorage _userStorage;

  static const STORAGE_KEY_AUTH_TOKEN = 'authToken';
  static const STORAGE_KEY_USER_DATA = 'data';
  static const STORAGE_FIRST_POSTS_DATA = 'firstPostsData';
  static const STORAGE_FIRST_NOTES_DATA = 'firstNotesData';
  static const STORAGE_TOP_POSTS_DATA = 'topPostsData';
  static const STORAGE_TOP_POSTS_LAST_VIEWED_ID = 'topPostsLastViewedId';

  static const STORAGE_FIRST_STORIES_DATA = 'firstStoriesData';

  AuthApiService _authApiService;
  HttpieService _httpieService;
  PostsApiService _postsApiService;
  ConnectionsApiService _connectionsApiService;
  NotificationsApiService _notificationsApiService;
  CreateAccountBloc _createAccountBlocService;
  DevicesApiService _devicesApiService;
  LocalizationService _localizationService;
  PushNotificationsService _pushNotificationService;
  IntercomService _intercomService;
  HashtagsApiService _hashtagsApiService;
  ConnectionsCirclesApiService _connectionsCirclesApiService;

  NotesApiService _notesApiService;

  CategoriesApiService _categoriesApiService;
  MoodsApiService _moodsApiService;
  ColorRangesApiService _colorRangesApiService;

  //CreateStoryBloc _createStoryBlocService;
  StoriesApiService _storiesApiService;

  DraftService _draftService;

  // If this is null, means user logged out.
  Stream<User> get loggedInUserChange => _loggedInUserChangeSubject.stream;

  User _loggedInUser;

  String _authToken;

  final _loggedInUserChangeSubject = ReplaySubject<User>(maxSize: 1);

  Future<Device> _getOrCreateCurrentDeviceCache;

  static const MAX_TEMP_DIRECTORY_CACHE_MB = 200; // 200mb

  void setAuthApiService(AuthApiService authApiService) {
    _authApiService = authApiService;
  }

  void setPushNotificationsService(
      PushNotificationsService pushNotificationsService) {
    _pushNotificationService = pushNotificationsService;
  }

  void setIntercomService(IntercomService intercomService) {
    _intercomService = intercomService;
  }

  void setConnectionsApiService(ConnectionsApiService connectionsApiService) {
    _connectionsApiService = connectionsApiService;
  }

  void setHashtagsApiService(HashtagsApiService hashtagsApiService) {
    _hashtagsApiService = hashtagsApiService;
  }

  void setNotificationsApiService(
      NotificationsApiService notificationsApiService) {
    _notificationsApiService = notificationsApiService;
  }

  void setDevicesApiService(DevicesApiService devicesApiService) {
    _devicesApiService = devicesApiService;
  }

  void setHttpieService(HttpieService httpieService) {
    _httpieService = httpieService;
  }

  void setStorageService(StorageService storageService) {
    _userStorage = storageService.getSecureStorage(namespace: 'user');
  }

  void setCreateAccountBlocService(CreateAccountBloc createAccountBloc) {
    _createAccountBlocService = createAccountBloc;
  }

  void setLocalizationsService(LocalizationService localizationService) {
    _localizationService = localizationService;
  }

  void setCategoriesApiService(CategoriesApiService categoriesApiService) {
    _categoriesApiService = categoriesApiService;
  }

  void setMoodsApiService(MoodsApiService moodsApiService) {
    _moodsApiService = moodsApiService;
  }

  void setColorRangesApiService(ColorRangesApiService colorRangesApiService) {
    _colorRangesApiService = colorRangesApiService;
  }

  /*void setCreateStoryBlocService(CreateStoryBloc createStoryBloc) {
    _createStoryBlocService = createStoryBloc;
  }*/

  void setStoriesApiServiceService(StoriesApiService storiesApiService) {
    _storiesApiService = storiesApiService;
  }

  void setPostsApiService(PostsApiService postsApiService) {
    _postsApiService = postsApiService;
  }


  void setConnectionsCirclesApiService(ConnectionsCirclesApiService circlesApiService) {
    _connectionsCirclesApiService = circlesApiService;
  }

  void setDraftService(DraftService draftService) {
    _draftService = draftService;
  }


  Future<void> deleteAccountWithPassword(String password) async {
    HttpieResponse response =
        await _authApiService.deleteUser(password: password);
    _checkResponseIsOk(response);
  }

  Future<void> logout() async {
    try {
      await _pushNotificationService.clearPromptedUserForPermission();
      await _intercomService.disableIntercom();
    } catch (error) {
      throw error;
    } finally {
      _deleteCurrentDevice();
      await _removeStoredUserData();
      await _removeStoredAuthToken();
      _httpieService.removeAuthorizationToken();
      _draftService.clear();
      _removeLoggedInUser();
      await clearCache();
      User.clearSessionCache();
      _getOrCreateCurrentDeviceCache = null;
    }
  }

  Future<void> clearCache() async {
    await _removeStoredFirstPostsData();
    await _removeStoredTopPostsData();
    await DiskCache().clear();
    await clearTemporaryDirectories();
    User.clearNavigationCache();
  }

  Future<bool> clearTemporaryDirectories() async {
    // TODO Handle every service clearing its own things responsible for, not have it
    // spread over the place...
    debugPrint('Clearing /tmp files and vimedia');
    try {
      Directory tempDir = Directory((await getApplicationDocumentsDirectory())
          .path
          .replaceFirst('Documents', 'tmp'));
      Directory vimediaDir = Directory(join(
          (await getApplicationDocumentsDirectory())
              .path
              .replaceFirst('Documents', 'tmp'),
          'vimedia'));
      Directory mediaCacheDir = Directory(
          join((await getApplicationDocumentsDirectory()).path, 'mediaCache'));
      Directory videoDirAndroid = Directory(
          join((await getApplicationDocumentsDirectory()).path, 'video'));

      if (tempDir.existsSync())
        tempDir.listSync().forEach((var entity) {
          if (entity is File) {
            entity.delete();
          }
        });
      if (vimediaDir.existsSync()) await vimediaDir.delete(recursive: true);
      if (mediaCacheDir.existsSync())
        await mediaCacheDir.delete(recursive: true);
      if (videoDirAndroid.existsSync())
        await videoDirAndroid.delete(recursive: true);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void checkAndClearTempDirectories() async {
    int size = 0;
    try {
      Directory tempDir = Directory((await getTemporaryDirectory())
          .path
          .replaceFirst('Documents', 'tmp'));
      Directory vimediaDir = Directory(join(
          (await getApplicationDocumentsDirectory())
              .path
              .replaceFirst('Documents', 'tmp'),
          'vimedia'));
      Directory videoDirAndroid =
          Directory(join((await getTemporaryDirectory()).path, 'video'));
      Directory mediaCacheDir =
          Directory(join((await getTemporaryDirectory()).path, 'mediaCache'));

      if (tempDir.existsSync())
        tempDir
            .listSync()
            .forEach((var entity) => size += entity.statSync().size);
      if (vimediaDir.existsSync())
        vimediaDir
            .listSync()
            .forEach((var entity) => size += entity.statSync().size);
      if (mediaCacheDir.existsSync())
        mediaCacheDir
            .listSync()
            .forEach((var entity) => size += entity.statSync().size);
      if (videoDirAndroid.existsSync())
        videoDirAndroid
            .listSync()
            .forEach((var entity) => size += entity.statSync().size);

      if (size > MAX_TEMP_DIRECTORY_CACHE_MB * 1000000) {
        clearTemporaryDirectories();
      }
    } catch (e) {
      debugPrint(e);
    }
  }

  Future<void> loginWithCredentials(
      {@required String username, @required String password}) async {
    HttpieResponse response = await _authApiService.loginWithCredentials(
        username: username, password: password);
    if (response.isOk()) {
      var parsedResponse = response.parseJsonBody();
      var authToken = parsedResponse['token'];
      await loginWithAuthToken(authToken);
    } else if (response.isUnauthorized()) {
      throw CredentialsMismatchError('The provided credentials do not match.');
    } else {
      throw HttpieRequestError(response);
    }
  }

  Future<void> requestPasswordReset({@required String email}) async {
    HttpieResponse response =
        await _authApiService.requestPasswordReset(email: email);
    _checkResponseIsOk(response);
  }

  Future<void> verifyPasswordReset(
      {@required String newPassword,
      @required String passwordResetToken}) async {
    HttpieResponse response = await _authApiService.verifyPasswordReset(
        newPassword: newPassword, passwordResetToken: passwordResetToken);
    _checkResponseIsOk(response);
  }

  Future<void> acceptGuidelines() async {
    HttpieResponse response = await _authApiService.acceptGuidelines();
    _checkResponseIsOk(response);
  }

  Future<void> loginWithAuthToken(String authToken) async {
    await _setAuthToken(authToken);
    await refreshUser();
  }

  User getLoggedInUser() {
    return _loggedInUser;
  }

  Language getUserLanguage() {
    return _loggedInUser.language;
  }

  bool isLoggedInUser(User user) {
    return user.id == _loggedInUser.id;
  }

  Future<User> refreshUser() async {
    if (_authToken == null) throw AuthTokenMissingError();

    HttpieResponse response =
        await _authApiService.getUserWithAuthToken(_authToken);
    _checkResponseIsOk(response);
    var userData = response.body;
    return _setUserWithData(userData);
  }

  Future<User> updateUserEmail(String email) async {
    HttpieStreamedResponse response =
        await _authApiService.updateUserEmail(email: email);
    _checkResponseIsOk(response);
    String userData = await response.readAsString();
    return _makeLoggedInUser(userData);
  }

  Future<void> updateUserPassword(
      String currentPassword, String newPassword) async {
    HttpieStreamedResponse response = await _authApiService.updateUserPassword(
        currentPassword: currentPassword, newPassword: newPassword);
    _checkResponseIsOk(response);
  }

  Future<User> updateUser({
    dynamic avatar,
    dynamic cover,
    String name,
    String username,
    String url,
    String password,
    bool followersCountVisible,
    bool communityPostsVisible,
    String bio,
    String location,
  }) async {
    HttpieStreamedResponse response = await _authApiService.updateUser(
        avatar: avatar,
        cover: cover,
        name: name,
        username: username,
        url: url,
        followersCountVisible: followersCountVisible,
        communityPostsVisible: communityPostsVisible,
        bio: bio,
        location: location);

    _checkResponseIsOk(response);

    String userData = await response.readAsString();
    return _makeLoggedInUser(userData);
  }

  Future<void> loginWithStoredUserData() async {
    var token = await _getStoredAuthToken();
    if (token == null &&
        !_createAccountBlocService.hasToken() &&
        !_createAccountBlocService.hasPasswordResetToken())
      throw AuthTokenMissingError();
    if (token == null && _createAccountBlocService.hasToken()) {
      print(
          'User is in register via link flow, dont throw error as it will break the flow');
      return;
    }
    if (token == null && _createAccountBlocService.hasPasswordResetToken()) {
      print(
          'User is in reset password via link flow, dont throw error as it will break the flow');
      return;
    }

    String userData = await this._getStoredUserData();
    if (userData != null) {
      var user = _makeLoggedInUser(userData);
      _setLoggedInUser(user);
    }

    await loginWithAuthToken(token);
  }

  Future<bool> hasAuthToken() async {
    String authToken = await _getStoredAuthToken();
    return authToken != null;
  }

  bool isLoggedIn() {
    return _loggedInUser != null;
  }

  Future<LanguagesList> getAllLanguages() async {
    HttpieResponse response = await this._authApiService.getAllLanguages();

    _checkResponseIsOk(response);

    return LanguagesList.fromJson(json.decode(response.body));
  }

  Future<void> setNewLanguage(Language newLanguage) async {
    HttpieResponse response =
        await this._authApiService.setNewLanguage(newLanguage);
    _checkResponseIsOk(response);
    await refreshUser();
  }

  Future<User> getUserWithUsername(String username) async {
    HttpieResponse response = await _authApiService
        .getUserWithUsername(username, authenticatedRequest: true);
    _checkResponseIsOk(response);
    return User.fromJson(json.decode(response.body));
  }

  Future<int> countPostsForUser(User user, {int maxId, int count}) async {
    HttpieResponse response =
        await _authApiService.getPostsCountForUserWithName(user.username);
    _checkResponseIsOk(response);
    User responseUser = User.fromJson(json.decode(response.body));
    return responseUser.postsCount;
  }

  Future<UsersList> getUsersWithQuery(String query) async {
    HttpieResponse response = await _authApiService.getUsersWithQuery(query,
        authenticatedRequest: true);
    _checkResponseIsOk(response);
    return UsersList.fromJson(json.decode(response.body));
  }

  Future<User> blockUser(User user) async {
    HttpieResponse response =
        await _authApiService.blockUserWithUsername(user.username);
    _checkResponseIsOk(response);
    return User.fromJson(json.decode(response.body));
  }

  Future<User> unblockUser(User user) async {
    HttpieResponse response =
        await _authApiService.unblockUserWithUsername(user.username);
    _checkResponseIsOk(response);
    return User.fromJson(json.decode(response.body));
  }

  Future<UsersList> searchBlockedUsers(
      {@required String query, int count}) async {
    HttpieResponse response =
        await _authApiService.searchBlockedUsers(query: query, count: count);
    _checkResponseIsOk(response);
    return UsersList.fromJson(json.decode(response.body));
  }

  Future<UsersList> getBlockedUsers({int maxId, int count}) async {
    HttpieResponse response =
        await _authApiService.getBlockedUsers(count: count, maxId: maxId);
    _checkResponseIsOk(response);
    return UsersList.fromJson(json.decode(response.body));
  }

  Future<User> disconnectFromUserWithUsername(String username) async {
    HttpieResponse response =
        await _connectionsApiService.disconnectFromUserWithUsername(username);
    _checkResponseIsOk(response);
    return User.fromJson(json.decode(response.body));
  }

  Future<HashtagsList> getHashtagsWithQuery(String query) async {
    HttpieResponse response =
        await _hashtagsApiService.getHashtagsWithQuery(query: query);
    _checkResponseIsOk(response);
    return HashtagsList.fromJson(json.decode(response.body));
  }

  Future<NotificationsList> getNotifications(
      {int maxId, int count, List<NotificationType> types}) async {
    HttpieResponse response = await _notificationsApiService.getNotifications(
        maxId: maxId, count: count, types: types);
    _checkResponseIsOk(response);
    return NotificationsList.fromJson(json.decode(response.body));
  }

  Future<int> getUnreadNotificationsCount(
      {int maxId, List<NotificationType> types}) async {
    HttpieResponse response = await _notificationsApiService
        .getUnreadNotificationsCount(maxId: maxId, types: types);
    _checkResponseIsOk(response);
    return (json.decode(response.body))['count'];
  }

  Future<OFNotification> getNotificationWithId(int notificationId) async {
    HttpieResponse response =
        await _notificationsApiService.getNotificationWithId(notificationId);
    _checkResponseIsOk(response);
    return OFNotification.fromJSON(json.decode(response.body));
  }

  Future<void> readNotifications(
      {int maxId, List<NotificationType> types}) async {
    HttpieResponse response = await _notificationsApiService.readNotifications(
        maxId: maxId, types: types);
    _checkResponseIsOk(response);
  }

  Future<void> deleteNotifications() async {
    HttpieResponse response =
        await _notificationsApiService.deleteNotifications();
    _checkResponseIsOk(response);
  }

  Future<void> deleteNotification(OFNotification notification) async {
    HttpieResponse response = await _notificationsApiService
        .deleteNotificationWithId(notification.id);
    _checkResponseIsOk(response);
  }

  Future<void> readNotification(OFNotification notification) async {
    HttpieResponse response =
        await _notificationsApiService.readNotificationWithId(notification.id);
    _checkResponseIsOk(response);
  }

  Future<DevicesList> getDevices() async {
    HttpieResponse response = await _devicesApiService.getDevices();
    _checkResponseIsOk(response);
    return DevicesList.fromJson(json.decode(response.body));
  }

  Future<void> deleteDevices() async {
    HttpieResponse response = await _devicesApiService.deleteDevices();
    _checkResponseIsOk(response);
  }

  Future<Device> createDevice({@required String uuid, String name}) async {
    HttpieResponse response =
        await _devicesApiService.createDevice(uuid: uuid, name: name);
    _checkResponseIsCreated(response);
    return Device.fromJSON(json.decode(response.body));
  }

  Future<Device> updateDevice(Device device, {String name}) async {
    HttpieResponse response = await _devicesApiService.updateDeviceWithUuid(
      device.uuid,
      name: name,
    );
    _checkResponseIsCreated(response);
    return Device.fromJSON(json.decode(response.body));
  }

  Future<void> deleteDevice(Device device) async {
    HttpieResponse response =
        await _devicesApiService.deleteDeviceWithUuid(device.uuid);
    _checkResponseIsOk(response);
  }

  Future<Device> getDeviceWithUuid(String deviceUuid) async {
    HttpieResponse response =
        await _devicesApiService.getDeviceWithUuid(deviceUuid);
    _checkResponseIsOk(response);
    return Device.fromJSON(json.decode(response.body));
  }

  Future<Device> getOrCreateCurrentDevice() async {
    if (_getOrCreateCurrentDeviceCache != null)
      return _getOrCreateCurrentDeviceCache;

    _getOrCreateCurrentDeviceCache = _getOrCreateCurrentDevice();
    _getOrCreateCurrentDeviceCache.catchError((error) {
      _getOrCreateCurrentDeviceCache = null;
      throw error;
    });

    return _getOrCreateCurrentDeviceCache;
  }

  Future<Device> _getOrCreateCurrentDevice() async {
    if (_getOrCreateCurrentDeviceCache != null)
      return _getOrCreateCurrentDeviceCache;

    String deviceUuid = await _getDeviceUuid();
    HttpieResponse response =
        await _devicesApiService.getDeviceWithUuid(deviceUuid);

    if (response.isNotFound()) {
      // Device does not exists, create one.
      String deviceName = await _getDeviceName();
      return createDevice(uuid: deviceUuid, name: deviceName);
    } else if (response.isOk()) {
      // Device exists
      return Device.fromJSON(json.decode(response.body));
    } else {
      throw HttpieRequestError(response);
    }
  }

  Future<void> _deleteCurrentDevice() async {
    if (_getOrCreateCurrentDeviceCache == null) return;

    Device currentDevice = await _getOrCreateCurrentDeviceCache;

    HttpieResponse response =
        await _devicesApiService.deleteDeviceWithUuid(currentDevice.uuid);

    if (!response.isOk() && !response.isNotFound()) {
      print('Could not delete current device');
    } else {
      print('Deleted current device successfully');
    }
  }

  Future<UserNotificationsSettings>
      getAuthenticatedUserNotificationsSettings() async {
    HttpieResponse response =
        await _authApiService.getAuthenticatedUserNotificationsSettings();
    _checkResponseIsOk(response);
    return UserNotificationsSettings.fromJSON(json.decode(response.body));
  }

  Future<UserNotificationsSettings>
      updateAuthenticatedUserNotificationsSettings({
    bool postCommentNotifications,
    bool postCommentReplyNotifications,
    bool postCommentReactionNotifications,
    bool postCommentUserMentionNotifications,
    bool postUserMentionNotifications,
    bool postReactionNotifications,
    bool followNotifications,
    bool connectionRequestNotifications,
    bool connectionConfirmedNotifications,
    bool communityInviteNotifications,
    bool communityNewPostNotifications,
    bool userNewPostNotifications,
  }) async {
    HttpieResponse response =
        await _authApiService.updateAuthenticatedUserNotificationsSettings(
            postCommentNotifications: postCommentNotifications,
            postCommentReplyNotifications: postCommentReplyNotifications,
            postCommentUserMentionNotifications:
                postCommentUserMentionNotifications,
            postUserMentionNotifications: postUserMentionNotifications,
            postCommentReactionNotifications: postCommentReactionNotifications,
            postReactionNotifications: postReactionNotifications,
            followNotifications: followNotifications,
            connectionConfirmedNotifications: connectionConfirmedNotifications,
            communityInviteNotifications: communityInviteNotifications,
            connectionRequestNotifications: connectionRequestNotifications,
            communityNewPostNotifications: communityNewPostNotifications,
            userNewPostNotifications: userNewPostNotifications);
    _checkResponseIsOk(response);
    return UserNotificationsSettings.fromJSON(json.decode(response.body));
  }

  Future<String> _getDeviceName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    String deviceName;

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceName = androidInfo.model;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      deviceName = iosDeviceInfo.utsname.machine;
    } else {
      deviceName = 'Unknown';
    }

    return deviceName;
  }

  Future<String> _getDeviceUuid() async {
    String identifier;

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      var build = await deviceInfo.androidInfo;
      identifier = build.androidId;
    } else if (Platform.isIOS) {
      var data = await deviceInfo.iosInfo;
      identifier = data.identifierForVendor;
    } else {
      throw 'Unsupported platform';
    }

    var bytes = utf8.encode(identifier);
    var digest = sha256.convert(bytes);

    return digest.toString();
  }

  Future<User> _setUserWithData(String userData) async {
    var user = _makeLoggedInUser(userData);
    _setLoggedInUser(user);
    await _storeUserData(userData);
    return user;
  }

  Future<void> setLanguageFromDefaults() async {
    Locale currentLocale = _localizationService.getLocale();
    LanguagesList languageList = await getAllLanguages();
    Language deviceLanguage =
        languageList.languages.firstWhere((Language language) {
      return language.code.toLowerCase() ==
          currentLocale.languageCode.toLowerCase();
    });

    if (deviceLanguage != null) {
      print('Setting language from defaults ${currentLocale.languageCode}');
      return await setNewLanguage(deviceLanguage);
    } else {
      Language english = languageList.languages.firstWhere(
          (Language language) => language.code.toLowerCase() == 'en');
      return await setNewLanguage(english);
    }
  }

  void _checkResponseIsCreated(HttpieBaseResponse response) {
    if (response.isCreated()) return;
    throw HttpieRequestError(response);
  }

  void _checkResponseIsOk(HttpieBaseResponse response) {
    if (response.isOk()) return;
    throw HttpieRequestError(response);
  }

  void _checkResponseIsAccepted(HttpieBaseResponse response) {
    if (response.isAccepted()) return;
    throw HttpieRequestError(response);
  }

  void _setLoggedInUser(User user) {
    if (_loggedInUser == null || _loggedInUser.id != user.id)
      _loggedInUserChangeSubject.add(user);
    _loggedInUser = user;
  }

  void _removeLoggedInUser() {
    _loggedInUser = null;
    _loggedInUserChangeSubject.add(null);
  }

  Future<void> _setAuthToken(String authToken) async {
    _authToken = authToken;
    _httpieService.setAuthorizationToken(authToken);
    await _storeAuthToken(authToken);
  }

  Future<void> _storeAuthToken(String authToken) {
    return _userStorage.set(STORAGE_KEY_AUTH_TOKEN, authToken);
  }

  Future<String> _getStoredAuthToken() async {
    String authToken = await _userStorage.get(STORAGE_KEY_AUTH_TOKEN);
    if (authToken != null) _authToken = authToken;
    return authToken;
  }

  Future<void> _removeStoredAuthToken() async {
    _userStorage.remove(STORAGE_KEY_AUTH_TOKEN);
  }

  Future<void> _storeUserData(String userData) {
    return _userStorage.set(STORAGE_KEY_USER_DATA, userData);
  }

  Future<void> _removeStoredUserData() async {
    _userStorage.remove(STORAGE_KEY_USER_DATA);
  }

  Future<String> _getStoredUserData() async {
    return _userStorage.get(STORAGE_KEY_USER_DATA);
  }

  Future<void> _removeStoredFirstPostsData() async {
    _userStorage.remove(STORAGE_FIRST_NOTES_DATA);
  }

  Future<String> _getStoredFirstPostsData() async {
    return _userStorage.get(STORAGE_FIRST_NOTES_DATA);
  }

  Future<void> _storeTopPostsData(String topPostsData) {
    return _userStorage.set(STORAGE_TOP_POSTS_DATA, topPostsData);
  }

  Future<void> _removeStoredTopPostsData() async {
    _userStorage.remove(STORAGE_TOP_POSTS_DATA);
  }

  Future<String> _getStoredTopPostsData() async {
    return _userStorage.get(STORAGE_TOP_POSTS_DATA);
  }

  Future<void> _storeTopPostsLastViewedId(String scrollPosition) {
    return _userStorage.set(STORAGE_TOP_POSTS_LAST_VIEWED_ID, scrollPosition);
  }

  Future<void> _removeStoredTopPostsLastViewedId() async {
    _userStorage.remove(STORAGE_TOP_POSTS_LAST_VIEWED_ID);
  }

  Future<String> _getStoredTopPostsLastViewedId() async {
    return _userStorage.get(STORAGE_TOP_POSTS_LAST_VIEWED_ID);
  }

  User _makeLoggedInUser(String userData) {
    return User.fromJson(json.decode(userData), storeInSessionCache: true);
  }

  // Note
  void setNotesApiService(NotesApiService notesApiService) {
    _notesApiService = notesApiService;
  }

  Future<NotesList> getNotes(
      {int maxId, int count, String username, bool cacheNotes = false}) async {
    /* HttpieResponse response = await _notesApiService.getNotes(
        maxId: maxId,
        count: count,
        username: username,
        authenticatedRequest: true);
    _checkResponseIsOk(response);
    String notesData = response.body;
    if (cacheNotes) {
      this._storeFirstNotesData(notesData);
    }
    return _makeNotesList(notesData);*/

    var notes = new List<Note>();
    for (int i = 0; i < 25; i++) {
      notes.add(new Note(
          id: i + 1,
          title: "Note " + (i + 1).toString(),
          uuid: (i + 1).toString()));
    }
    var notesList = new NotesList(notes: notes);
    return notesList;
  }

  NotesList _makeNotesList(String notesData) {
    return NotesList.fromJson(json.decode(notesData));
  }

  Future<void> _storeFirstNotesData(String firstNotesData) {
    return _userStorage.set(STORAGE_FIRST_NOTES_DATA, firstNotesData);
  }

  Future<List<TaskWidget>> getTaskWidgets() async {
    List<TaskWidget> taskWidgets = [];
    taskWidgets.add(TaskWidget(
      id: 1,
      state: TaskWidgetState.Today,
      name: TaskWidgetState.Today.toString(),
      color: ColorRange(
          color: Color.fromRGBO(98, 159, 239, 1).value,
          start: Color.fromRGBO(121, 153, 242, 1).value,
          end: Color.fromRGBO(105, 157, 240, 1).value),
    ));
    taskWidgets.add(TaskWidget(
      id: 2,
      state: TaskWidgetState.Scheduled,
      name: TaskWidgetState.Scheduled.toString(),
      color: ColorRange(
          color: Color.fromRGBO(120, 112, 189, 1).value,
          start: Color.fromRGBO(132, 137, 227, 1).value,
          end: Color.fromRGBO(127, 127, 210, 1).value),
    ));
    taskWidgets.add(TaskWidget(
      id: 3,
      state: TaskWidgetState.All,
      name: TaskWidgetState.All.toString(),
      color: ColorRange(
          color: Color.fromRGBO(89, 157, 166, 1).value,
          start: Color.fromRGBO(134, 217, 164, 1).value,
          end: Color.fromRGBO(100, 172, 165, 1).value),
    ));
    taskWidgets.add(TaskWidget(
      id: 4,
      state: TaskWidgetState.Flagged,
      name: TaskWidgetState.Flagged.toString(),
      color: ColorRange(
          color: Color.fromRGBO(230, 113, 153, 1).value,
          start: Color.fromRGBO(237, 122, 129, 1).value,
          end: Color.fromRGBO(232, 116, 144, 1).value),
    ));

    return taskWidgets;
  }

  Future<List<TaskList>> getTaskLists() async {
    List<TaskList> taskLists = [];
    for (var i = 0; i < 3; i++) {
      taskLists.add(new TaskList(
        id: i + 1,
        name: "Task " + (i + 1).toString(),
        active: true,
        color: ColorRange(
            color: Color.fromRGBO(230, 113, 153, 1).value,
            start: Color.fromRGBO(237, 122, 129, 1).value,
            end: Color.fromRGBO(232, 116, 144, 1).value),
      ));
    }
    return taskLists;
  }

  Future<TaskList> getTaskListByState(TaskWidgetState state) async {
    TaskList taskList = new TaskList(
        id: 1,
        name: "Task List 1",
        active: true,
        color: ColorRange(
            color: Color.fromRGBO(230, 113, 153, 1).value,
            start: Color.fromRGBO(237, 122, 129, 1).value,
            end: Color.fromRGBO(232, 116, 144, 1).value));

    List<Task> tasks = new List<Task>();
    for (var i = 0; i < 10; i++) {
      tasks.add(new Task(
        id: i + 1,
        name: "Task " + (i + 1).toString(),
        dueDate: DateTime.now(),
        active: true,
      ));
    }
    taskList.tasks = new TasksList(tasks: tasks);

    return taskList;
  }

  Future<TaskHomeList> getTaskHomeList() async {
    var taskHomeList = new TaskHomeList(taskHomes: new List<TaskHome>());

    for (var i = 0; i < 5; i++) {
      var taskHome = new TaskHome();
      taskHome.name = (i + 1).toString();
      List<Task> tasks = new List<Task>();
      for (var i = 0; i < 4; i++) {
        tasks.add(new Task(
          id: i + 1,
          name: "Task " + (i + 1).toString(),
          dueDate: DateTime.now(),
          active: true,
        ));
      }
      taskHome.tasks = new TasksList(tasks: tasks);
      taskHomeList.taskHomes.add(taskHome);
    }

    return taskHomeList;
  }

  Future<Task> getTaskWithUuid(String uuid) async {
    /* HttpieResponse response = await _postsApiService.getPostWithUuid(uuid);
    _checkResponseIsOk(response);
    return Task.fromJson(json.decode(response.body));*/

    return null;
  }

  Future<void> publishTask({@required Task task}) async {
    /* HttpieResponse response =
        await _tasksApiService.publishPost(postUuid: task.uuid);

    _checkResponseIsOk(response);*/
  }

  Future<OFTaskStatus> getTaskStatus({@required Task task}) async {
    /* HttpieResponse response =
        await _postsApiService.getPostWithUuidStatus(task.uuid);

    _checkResponseIsOk(response);

    Map<String, dynamic> responseJson = response.parseJsonBody();

    OFTaskStatus status = OFTaskStatus.parse(responseJson['status']);

    task.setStatus(status);

    return status;*/

    return OFTaskStatus.draft;
  }

  Future<Task> editTask({String taskUuid, String text}) async {
    /* HttpieStreamedResponse response =
        await _postsApiService.editPost(taskUuid: taskUuid, text: text);

    _checkResponseIsOk(response);

    String responseBody = await response.readAsString();
    return Task.fromJson(json.decode(responseBody));*/

    return null;
  }

  Future<void> deleteTask(Task task) async {
    /* HttpieResponse response =
        await _postsApiService.deletePostWithUuid(task.uuid);
    _checkResponseIsOk(response);*/
  }

  // Stories
  Future<void> _storeFirstStoriesData(String firstPostsData) {
    return _userStorage.set(STORAGE_FIRST_STORIES_DATA, firstPostsData);
  }

  Future<String> _getStoredFirstStoriesData() async {
    return _userStorage.get(STORAGE_FIRST_STORIES_DATA);
  }

  /*StoriesList _makeStoriesList(String storiesData) {
    return StoriesList.fromJson(json.decode(storiesData));
  }

  Future<StoriesList> getStoredFirstPosts() async {
    String firstStoriesData = await this._getStoredFirstStoriesData();
    if (firstStoriesData != null) {
      var storiesList = _makeStoriesList(firstStoriesData);
      return storiesList;
    }
    return StoriesList();
  }

  Future<StoriesList> getStories(
      {int maxId,
        int count,
        String username,
        bool cacheStories = false}) async {
    HttpieResponse response = await _storiesApiService.getStories(
        maxId: maxId,
        count: count,
        username: username,
        authenticatedRequest: true);
    _checkResponseIsOk(response);
    String storiesData = response.body;
    if (cacheStories) {
      this._storeFirstStoriesData(storiesData);
    }
    return _makeStoriesList(storiesData);
  }

  Future<Story> createStory({String title, Category category, Mood mood}) async {
    HttpieResponse response = await _storiesApiService.createStory(
        title: title,
        category: category,
        mood: mood,
        owner: getLoggedInUser());

    _checkResponseIsOk(response);

    return Story.fromJson(json.decode(response.body));
  }*/

  // Commons
  Future<CategoriesList> getCategories() async {
    HttpieResponse response = await _categoriesApiService.getCategories();
    _checkResponseIsOk(response);
    return CategoriesList.fromJson(json.decode(response.body));
  }

  Future<MoodsList> getMoods() async {
    HttpieResponse response = await _moodsApiService.getMoods();
    _checkResponseIsOk(response);
    return MoodsList.fromJson(json.decode(response.body));
  }

  // Posts
  PostsList _makePostsList(String postsData) {
    return PostsList.fromJson(json.decode(postsData));
  }

  Future<void> _storeFirstPostsData(String firstPostsData) {
    return _userStorage.set(STORAGE_FIRST_POSTS_DATA, firstPostsData);
  }

  Future<PostsList> getStoredFirstPosts() async {
    String firstPostsData = await this._getStoredFirstPostsData();
    if (firstPostsData != null) {
      var postsList = _makePostsList(firstPostsData);
      return postsList;
    }
    return PostsList();
  }

  Future<PostsList> getTimelinePosts(
      {List<Circle> circles = const [],
        List<FollowsList> followsLists = const [],
        int maxId,
        int count,
        String username,
        bool cachePosts = false}) async {
    HttpieResponse response = await _postsApiService.getTimelinePosts(
        circleIds: circles.map((circle) => circle.id).toList(),
        listIds: followsLists.map((followsList) => followsList.id).toList(),
        maxId: maxId,
        count: count,
        username: username,
        authenticatedRequest: true);
    _checkResponseIsOk(response);
    String postsData = response.body;
    if (cachePosts) {
      this._storeFirstPostsData(postsData);
    }
    return _makePostsList(postsData);
  }

  Future<Post> createPost(
      {String text, List<Circle> circles = const [], bool isDraft}) async {
    HttpieStreamedResponse response = await _postsApiService.createPost(
        text: text,
        circleIds: circles.map((circle) => circle.id).toList(),
        isDraft: isDraft);

    _checkResponseIsCreated(response);

    // Post counts may have changed
    refreshUser();

    String responseBody = await response.readAsString();
    return Post.fromJson(json.decode(responseBody));
  }

  Future<Post> editPost({String postUuid, String text}) async {
    HttpieStreamedResponse response =
    await _postsApiService.editPost(postUuid: postUuid, text: text);

    _checkResponseIsOk(response);

    String responseBody = await response.readAsString();
    return Post.fromJson(json.decode(responseBody));
  }

  Future<void> deletePost(Post post) async {
    HttpieResponse response =
    await _postsApiService.deletePostWithUuid(post.uuid);
    _checkResponseIsOk(response);
  }

  Future<void> publishPost({@required Post post}) async {
    HttpieResponse response =
    await _postsApiService.publishPost(postUuid: post.uuid);

    _checkResponseIsOk(response);
  }

  Future<Post> createPostForCommunity(Community community,
      {String text, File image, File video, bool isDraft}) async {
   /* HttpieStreamedResponse response = await _communitiesApiService
        .createPostForCommunityWithId(community.name,
        text: text, image: image, video: video, isDraft: isDraft);
    _checkResponseIsCreated(response);

    String responseBody = await response.readAsString();

    return Post.fromJson(json.decode(responseBody));*/
   return null;
  }

  Future<Post> getPostWithUuid(String uuid) async {
    HttpieResponse response = await _postsApiService.getPostWithUuid(uuid);
    _checkResponseIsOk(response);
    return Post.fromJson(json.decode(response.body));
  }

  Future<OBPostStatus> getPostStatus({@required Post post}) async {
    HttpieResponse response =
    await _postsApiService.getPostWithUuidStatus(post.uuid);

    _checkResponseIsOk(response);

    Map<String, dynamic> responseJson = response.parseJsonBody();

    OBPostStatus status = OBPostStatus.parse(responseJson['status']);

    post.setStatus(status);

    return status;
  }

  Future<PostReaction> reactToPost(
      {@required Post post, @required Emoji emoji}) async {
    HttpieResponse response = await _postsApiService.reactToPost(
        postUuid: post.uuid, emojiId: emoji.id);
    _checkResponseIsCreated(response);
    return PostReaction.fromJson(json.decode(response.body));
  }

  Future<void> deletePostReaction(
      {@required PostReaction postReaction, @required Post post}) async {
    HttpieResponse response = await _postsApiService.deletePostReaction(
        postReactionId: postReaction.id, postUuid: post.uuid);
    _checkResponseIsOk(response);
  }

  Future<String> translatePost({@required Post post}) async {
    HttpieResponse response =
    await _postsApiService.translatePost(postUuid: post.uuid);

    _checkResponseIsOk(response);

    return json.decode(response.body)['translated_text'];
  }

  Future<String> translatePostComment(
      {@required Post post, @required PostComment postComment}) async {
    HttpieResponse response = await _postsApiService.translatePostComment(
        postUuid: post.uuid, postCommentId: postComment.id);

    _checkResponseIsOk(response);

    return json.decode(response.body)['translated_text'];
  }

  // Media
  Future<void> addMediaToPost(
      {@required File file, @required Post post}) async {
    HttpieStreamedResponse response =
    await _postsApiService.addMediaToPost(file: file, postUuid: post.uuid);

    _checkResponseIsOk(response);
  }

  Future<PostMediaList> getMediaForPost({@required Post post}) async {
    HttpieResponse response =
    await _postsApiService.getPostMedia(postUuid: post.uuid);

    _checkResponseIsOk(response);

    return PostMediaList.fromJson(json.decode(response.body));
  }


  // Emoji
  Future<EmojiGroupList> getEmojiGroups() async {
    /*HttpieResponse response = await this._emojisApiService.getEmojiGroups();

    _checkResponseIsOk(response);

    return EmojiGroupList.fromJson(json.decode(response.body));*/

    return null;
  }

  Future<EmojiGroupList> getReactionEmojiGroups() async {
    HttpieResponse response =
    await this._postsApiService.getReactionEmojiGroups();

    _checkResponseIsOk(response);

    return EmojiGroupList.fromJson(json.decode(response.body));
  }

  // Circles
  Future<CirclesList> getConnectionsCircles() async {
    HttpieResponse response = await _connectionsCirclesApiService.getCircles();
    _checkResponseIsOk(response);
    return CirclesList.fromJson(json.decode(response.body));
  }

  // PostComment
  Future<PostComment> commentPost(
      {@required Post post, @required String text}) async {
    HttpieResponse response =
    await _postsApiService.commentPost(postUuid: post.uuid, text: text);
    _checkResponseIsCreated(response);
    return PostComment.fromJSON(json.decode(response.body));
  }

  Future<PostComment> editPostComment(
      {@required Post post,
        @required PostComment postComment,
        @required String text}) async {
    HttpieResponse response = await _postsApiService.editPostComment(
        postUuid: post.uuid, postCommentId: postComment.id, text: text);
    _checkResponseIsOk(response);
    return PostComment.fromJSON(json.decode(response.body));
  }

  Future<PostComment> getPostComment(
      {@required Post post, @required PostComment postComment}) async {
    HttpieResponse response = await _postsApiService.getPostComment(
        postUuid: post.uuid, postCommentId: postComment.id);
    _checkResponseIsOk(response);
    return PostComment.fromJSON(json.decode(response.body));
  }

  Future<PostComment> replyPostComment(
      {@required Post post,
        @required PostComment postComment,
        @required String text}) async {
    HttpieResponse response = await _postsApiService.replyPostComment(
        postUuid: post.uuid, postCommentId: postComment.id, text: text);
    _checkResponseIsCreated(response);
    return PostComment.fromJSON(json.decode(response.body));
  }

  Future<void> deletePostComment(
      {@required PostComment postComment, @required Post post}) async {
    HttpieResponse response = await _postsApiService.deletePostComment(
        postCommentId: postComment.id, postUuid: post.uuid);
    _checkResponseIsOk(response);
  }

  Future<Post> mutePost(Post post) async {
    HttpieResponse response =
    await _postsApiService.mutePostWithUuid(post.uuid);
    _checkResponseIsOk(response);
    return Post.fromJson(json.decode(response.body));
  }

  Future<Post> unmutePost(Post post) async {
    HttpieResponse response =
    await _postsApiService.unmutePostWithUuid(post.uuid);
    _checkResponseIsOk(response);
    return Post.fromJson(json.decode(response.body));
  }

  Future<PostCommentList> getCommentsForPost(Post post,
      {int maxId,
        int countMax,
        int minId,
        int countMin,
        PostCommentsSortType sort}) async {
    HttpieResponse response = await _postsApiService.getCommentsForPostWithUuid(
        post.uuid,
        countMax: countMax,
        maxId: maxId,
        countMin: countMin,
        minId: minId,
        sort: sort != null
            ? PostComment.convertPostCommentSortTypeToString(sort)
            : null);

    _checkResponseIsOk(response);
    return PostCommentList.fromJson(json.decode(response.body));
  }

  Future<PostCommentList> getCommentRepliesForPostComment(
      Post post, PostComment postComment,
      {int maxId,
        int countMax,
        int minId,
        int countMin,
        PostCommentsSortType sort}) async {
    HttpieResponse response = await _postsApiService
        .getRepliesForCommentWithIdForPostWithUuid(post.uuid, postComment.id,
        countMax: countMax,
        maxId: maxId,
        countMin: countMin,
        minId: minId,
        sort: sort != null
            ? PostComment.convertPostCommentSortTypeToString(sort)
            : null);

    _checkResponseIsOk(response);
    return PostCommentList.fromJson(json.decode(response.body));
  }

  // PostCommentReaction
  Future<PostCommentReaction> reactToPostComment(
      {@required Post post,
        @required PostComment postComment,
        @required Emoji emoji}) async {
    HttpieResponse response = await _postsApiService.reactToPostComment(
      postCommentId: postComment.id,
      postUuid: post.uuid,
      emojiId: emoji.id,
    );
    _checkResponseIsCreated(response);
    return PostCommentReaction.fromJson(json.decode(response.body));
  }

  Future<void> deletePostCommentReaction(
      {@required PostCommentReaction postCommentReaction,
        @required PostComment postComment,
        @required Post post}) async {
    HttpieResponse response = await _postsApiService.deletePostCommentReaction(
        postCommentReactionId: postCommentReaction.id,
        postUuid: post.uuid,
        postCommentId: postComment.id);
    _checkResponseIsOk(response);
  }

  Future<PostCommentReactionList> getReactionsForPostComment(
      {PostComment postComment,
        Post post,
        int count,
        int maxId,
        Emoji emoji}) async {
    HttpieResponse response = await _postsApiService.getReactionsForPostComment(
        postUuid: post.uuid,
        postCommentId: postComment.id,
        count: count,
        maxId: maxId,
        emojiId: emoji.id);

    _checkResponseIsOk(response);

    return PostCommentReactionList.fromJson(json.decode(response.body));
  }

}

class CredentialsMismatchError implements Exception {
  final String msg;

  const CredentialsMismatchError(this.msg);

  String toString() => 'CredentialsMismatchError: $msg';
}

class AuthTokenMissingError implements Exception {
  const AuthTokenMissingError();

  String toString() => 'AuthTokenMissingError: No auth token was found.';
}

class NotLoggedInUserError implements Exception {
  const NotLoggedInUserError();

  String toString() => 'NotLoggedInUserError: No user is logged in.';
}
