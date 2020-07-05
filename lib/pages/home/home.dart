import 'dart:async';
import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/models/push_notification.dart';
import 'package:onef/models/user.dart';
import 'package:onef/pages/home/lib/poppable_page_controller.dart';
import 'package:onef/pages/home/pages/main.dart';
import 'package:onef/pages/home/pages/note/note_page.dart';
import 'package:onef/pages/home/pages/search/search.dart';
import 'package:onef/pages/home/pages/task/task_home_page.dart';
import 'package:onef/pages/home/pages/task/task_list_page.dart';
import 'package:onef/pages/home/pages/widgets/bottom-tab-bar.dart';
import 'package:onef/pages/home/pages/widgets/own_profile_active_icon.dart';
import 'package:onef/pages/home/pages/widgets/tab-scaffold.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/intercom.dart';
import 'package:onef/services/modal_service.dart';
import 'package:onef/services/push_notifications.dart';
import 'package:onef/services/share.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/services/user_preferences.dart';
import 'package:onef/translation/constants.dart';
import 'package:onef/widgets/avatars/avatar.dart';
import 'package:onef/widgets/drawable.dart';
import 'package:onef/widgets/icon.dart';

class OFHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OFHomePageState();
  }
}

class OFHomePageState extends State<OFHomePage> with WidgetsBindingObserver {
  int _currentIndex;
  int _lastIndex;
  bool _needsBootstrap;

  UserService _userService;
  ToastService _toastService;
  PushNotificationsService _pushNotificationsService;
  IntercomService _intercomService;
  ModalService _modalService;
  UserPreferencesService _userPreferencesService;
  ShareService _shareService;

  StreamSubscription _loggedInUserChangeSubscription;
  StreamSubscription _loggedInUserUpdateSubscription;
  StreamSubscription _pushNotificationOpenedSubscription;
  StreamSubscription _pushNotificationSubscription;

  OFMainPageController _mainPageController;
  //OFStoryPageController _storyPageController;
  OFTaskHomePageController _taskHomePageController;
  OFTaskListPageController _taskListPageController;
  OFNotePageController _notePageController;
  OFMainSearchPageController _searchPageController;

  int _loggedInUserUnreadNotifications;
  String _loggedInUserAvatarUrl;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(_backButtonInterceptor);
    WidgetsBinding.instance.addObserver(this);
    _lastIndex = 0;
    _currentIndex = 0;
    _needsBootstrap = true;
    _loggedInUserUnreadNotifications = 0;
    _mainPageController = OFMainPageController();
    //_storyPageController = OFStoryPageController();
    _taskHomePageController = OFTaskHomePageController();
    _taskListPageController = OFTaskListPageController();
    _notePageController = OFNotePageController();
    _searchPageController = OFMainSearchPageController();
  }

  @override
  void dispose() {
    super.dispose();
    BackButtonInterceptor.remove(_backButtonInterceptor);
    WidgetsBinding.instance.removeObserver(this);
    _loggedInUserChangeSubscription.cancel();
    if (_loggedInUserUpdateSubscription != null)
      _loggedInUserUpdateSubscription.cancel();
    if (_pushNotificationOpenedSubscription != null) {
      _pushNotificationOpenedSubscription.cancel();
    }
    if (_pushNotificationSubscription != null) {
      _pushNotificationSubscription.cancel();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      bool hasAuthToken = await _userService.hasAuthToken();
      if (hasAuthToken) _userService.refreshUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OneFProvider.of(context);
      _userService = provider.userService;
      _pushNotificationsService = provider.pushNotificationsService;
      _intercomService = provider.intercomService;
      _toastService = provider.toastService;
      _modalService = provider.modalService;
      _userPreferencesService = provider.userPreferencesService;
      _shareService = provider.shareService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return Material(
      child: OFCupertinoTabScaffold(
        tabBuilder: (BuildContext context, int index) {
          return CupertinoTabView(
            builder: (BuildContext context) {
              return _getPageForTabIndex(index);
            },
          );
        },
        tabBar: _createTabBar(),
      ),
    );
  }

  void _navigateToTab(OFHomePageTabs tab) {
    int newIndex = OFHomePageTabs.values.indexOf(tab);
    // This only works once... bug with flutter.
    // Reported it here https://github.com/flutter/flutter/issues/28992
    _setCurrentIndex(newIndex);
  }

  void _setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _getPageForTabIndex(int index) {
    Widget page;
    switch (OFHomePageTabs.values[index]) {
     /* case OFHomePageTabs.main:
        page = OFStoryPage(
          controller: _storyPageController,
        );
        break;*/
      case OFHomePageTabs.task:
        page = OFTaskListPage(
          controller: _taskListPageController,
        );
        break;
      case OFHomePageTabs.note:
        page = OFNotePage(
          controller: _notePageController,
        );
        break;
      case OFHomePageTabs.search:
        page = OFMainSearchPage(
          controller: _searchPageController,
        );
        break;
      case OFHomePageTabs.profile:
        page = OFMainPage(
          controller: _mainPageController,
        );
        break;
      default:
        throw 'Unhandled index';
    }

    return page;
  }

  Widget _createTabBar() {
    return OFCupertinoTabBar(
      backgroundColor: Colors.white,
      currentIndex: _currentIndex,
      onTap: (int index) {
        var tappedTab = OFHomePageTabs.values[index];
        var currentTab = OFHomePageTabs.values[_lastIndex];
/*
        if (tappedTab == OFHomePageTabs.main &&
            currentTab == OFHomePageTabs.main) {
          if (_mainPageController.isFirstRoute()) {
            _mainPageController.scrollToTop();
          } else {
            _mainPageController.popUntilFirstRoute();
          }
        }*/

        /*if (tappedTab == OFHomePageTabs.main &&
            currentTab == OFHomePageTabs.main) {
          _storyPageController.popUntilFirstRoute();
        }*/

        /* if (tappedTab == OFHomePageTabs.task &&
            currentTab == OFHomePageTabs.task) {
          if (_taskPageController.isFirstRoute()) {
            _taskPageController.scrollToTop();
          } else {
            _taskPageController.popUntilFirstRoute();
          }
        }*/

        if (tappedTab == OFHomePageTabs.note &&
            currentTab == OFHomePageTabs.note) {
          if (_notePageController.isFirstRoute()) {
            _notePageController.scrollToTop();
          } else {
            _notePageController.popUntilFirstRoute();
          }
        }

        if (tappedTab == OFHomePageTabs.search &&
            currentTab == OFHomePageTabs.search) {
          if (_searchPageController.isFirstRoute()) {
            _searchPageController.scrollToTop();
          } else {
            _searchPageController.popUntilFirstRoute();
          }
        }

        if (tappedTab == OFHomePageTabs.profile &&
            currentTab == OFHomePageTabs.profile) {
          if (_mainPageController.isFirstRoute()) {
            _mainPageController.scrollToTop();
          } else {
            _mainPageController.popUntilFirstRoute();
          }
        }

        _lastIndex = index;
        return true;
      },
      items: [
        BottomNavigationBarItem(
          title: const SizedBox(),
          icon: const OFIcon(OFIconData(nativeIcon: D.love1)),
          activeIcon: const OFIcon(
            OFIconData(nativeIcon: D.love1),
            themeColor: OFIconThemeColor.primaryAccent,
          ),
        ),
        BottomNavigationBarItem(
          title: const SizedBox(),
          icon: const OFIcon(OFIconData(nativeIcon: D.check0)),
          activeIcon: const OFIcon(
            OFIconData(nativeIcon: D.check0),
            themeColor: OFIconThemeColor.primaryAccent,
          ),
        ),
        BottomNavigationBarItem(
          title: const SizedBox(),
          icon: const OFIcon(OFIconData(nativeIcon: D.note0)),
          activeIcon: const OFIcon(
            OFIconData(nativeIcon: D.note0),
            themeColor: OFIconThemeColor.primaryAccent,
          ),
        ),
        BottomNavigationBarItem(
          title: const SizedBox(),
          icon: const OFIcon(OFIcons.search),
          activeIcon: const OFIcon(
            OFIcons.search,
            themeColor: OFIconThemeColor.primaryAccent,
          ),
        ),
        BottomNavigationBarItem(
            title: const SizedBox(),
            icon: _loggedInUserAvatarUrl == null
                ? const OFIcon(OFIconData(nativeIcon: D.account0))
                : OFAvatar(
                    avatarUrl: _loggedInUserAvatarUrl,
                    size: OFAvatarSize.extraSmall,
                  ),
            activeIcon: _loggedInUserAvatarUrl == null
                ? const OFIcon(
                    OFIconData(nativeIcon: D.account0),
                    themeColor: OFIconThemeColor.primaryAccent,
                  )
                : OFOwnProfileActiveIcon(
                    avatarUrl: _loggedInUserAvatarUrl,
                    size: OFAvatarSize.extraSmall,
                  )),
      ],
    );
  }

  void _bootstrap() async {
    _loggedInUserChangeSubscription =
        _userService.loggedInUserChange.listen(_onLoggedInUserChange);

    if (!_userService.isLoggedIn()) {
      try {
        await _userService.loginWithStoredUserData();
      } catch (error) {
        if (error is AuthTokenMissingError) {
          _logout();
        } else if (error is HttpieRequestError) {
          HttpieResponse response = error.response;
          if (response.isForbidden() || response.isUnauthorized()) {
            _logout(unsubscribePushNotifications: true);
          } else {
            _onError(error);
          }
        } else {
          _onError(error);
        }
      }
    }

    //_shareService.subscribe(_onShare);
  }

  Future _logout({unsubscribePushNotifications = false}) async {
    try {
      if (unsubscribePushNotifications)
        await _pushNotificationsService.unsubscribeFromPushNotifications();
    } catch (error) {
      throw error;
    } finally {
      await _userService.logout();
    }
  }

  bool _backButtonInterceptor(bool stopDefaultButtonEvent) {
    OFHomePageTabs currentTab = OFHomePageTabs.values[_lastIndex];
    PoppablePageController currentTabController;

    switch (currentTab) {
    /*  case OFHomePageTabs.main:
        currentTabController = _storyPageController;
        break;*/
      case OFHomePageTabs.task:
        currentTabController = _taskHomePageController;
        break;
      case OFHomePageTabs.note:
        currentTabController = _notePageController;
        break;
        break;
      case OFHomePageTabs.search:
        currentTabController = _searchPageController;
        break;
      case OFHomePageTabs.profile:
        currentTabController = _mainPageController;
        break;
      default:
        throw 'No tab controller to pop';
    }

    bool canPopRootRoute = Navigator.of(context, rootNavigator: true).canPop();
    bool canPopRoute = currentTabController.canPop();
    bool preventCloseApp = false;

    if (canPopRoute && !canPopRootRoute) {
      currentTabController.pop();
      // Stop default
      preventCloseApp = true;
    }

    // Close the app
    return preventCloseApp;
  }

  void _onLoggedInUserChange(User newUser) async {
    if (newUser == null) {
      Navigator.pushReplacementNamed(context, '/auth');
    } else {
      _pushNotificationsService.bootstrap();
      _intercomService.enableIntercom();

      _loggedInUserUpdateSubscription =
          newUser.updateSubject.listen(_onLoggedInUserUpdate);

      _pushNotificationOpenedSubscription = _pushNotificationsService
          .pushNotificationOpened
          .listen(_onPushNotificationOpened);

      _pushNotificationSubscription = _pushNotificationsService.pushNotification
          .listen(_onPushNotification);

      if (newUser.language == null ||
          !supportedLanguages.contains(newUser.language.code)) {
        _userService.setLanguageFromDefaults();
      }
      _userService.checkAndClearTempDirectories();
    }
  }

  void _onPushNotification(PushNotification pushNotification) {}

  void _onPushNotificationOpened(
      PushNotificationOpenedResult pushNotificationOpenedResult) {
    //_navigateToTab(OBHomePageTabs.notifications);
  }

  Future<bool> _onShare({String text, File image, File video}) async {
    return true;
  }

  void _onLoggedInUserUpdate(User user) {
    _setAvatarUrl(user.getProfileAvatar());
  }

  void _setAvatarUrl(String avatarUrl) {
    setState(() {
      _loggedInUserAvatarUrl = avatarUrl;
    });
  }

  void _setUnreadNotifications(int unreadNotifications) {
    setState(() {
      _loggedInUserUnreadNotifications = unreadNotifications;
    });
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage, context: context);
    } else {
      _toastService.error(message: 'Unknown error', context: context);
      throw error;
    }
  }
}

enum OFHomePageTabs { main, task, note, search, profile }
