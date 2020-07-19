import 'package:flutter/material.dart';
import 'package:onef/pages/auth/create_account/blocs/create_account.dart';
import 'package:onef/plugins/proxy_settings.dart';
import 'package:onef/services/auth_api.dart';
import 'package:onef/services/bottom_sheet.dart';
import 'package:onef/services/categories_api.dart';
import 'package:onef/services/color_ranges_api.dart';
import 'package:onef/services/connections_api.dart';
import 'package:onef/services/connections_circles_api.dart';
import 'package:onef/services/connectivity.dart';
import 'package:onef/services/date_picker.dart';
import 'package:onef/services/devices_api.dart';
import 'package:onef/services/dialog.dart';
import 'package:onef/services/draft.dart';
import 'package:onef/services/environment_loader.dart';
import 'package:onef/services/hashtags_api.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/intercom.dart';
import 'package:onef/services/link_preview.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/media/media.dart';
import 'package:onef/services/modal_service.dart';
import 'package:onef/services/moods_api.dart';
import 'package:onef/services/navigation_service.dart';
import 'package:onef/services/notes_api.dart';
import 'package:onef/services/notifications_api.dart';
import 'package:onef/services/permissions.dart';
import 'package:onef/services/posts_api.dart';
import 'package:onef/services/push_notifications.dart';
import 'package:onef/services/share.dart';
import 'package:onef/services/storage.dart';
import 'package:onef/services/stories_api.dart';
import 'package:onef/services/string_template.dart';
import 'package:onef/services/text_autocompletion.dart';
import 'package:onef/services/theme.dart';
import 'package:onef/services/theme_value_parser.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/url_launcher.dart';
import 'package:onef/services/user.dart';
import 'package:onef/services/user_preferences.dart';
import 'package:onef/services/utils_service.dart';
import 'package:onef/services/validation.dart';
import 'package:sentry/sentry.dart';

class OneFProvider extends StatefulWidget {
  final Widget child;

  const OneFProvider({Key key, @required this.child}) : super(key: key);

  @override
  OneFProviderState createState() {
    return OneFProviderState();
  }

  static OneFProviderState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_OneFProvider)
            as _OneFProvider)
        .data;
  }
}

class OneFProviderState extends State<OneFProvider> {
  UserPreferencesService userPreferencesService = UserPreferencesService();
  CreateAccountBloc createAccountBloc = CreateAccountBloc();

  //CreateStoryBloc createStoryBloc = CreateStoryBloc();
  UrlLauncherService urlLauncherService = UrlLauncherService();
  ValidationService validationService = ValidationService();
  HttpieService httpService = HttpieService();
  AuthApiService authApiService = AuthApiService();
  StorageService storageService = StorageService();
  UserService userService = UserService();
  ToastService toastService = ToastService();
  StringTemplateService stringTemplateService = StringTemplateService();
  NotificationsApiService notificationsApiService = NotificationsApiService();
  DevicesApiService devicesApiService = DevicesApiService();
  ModalService modalService = ModalService();
  ConnectionsApiService connectionsApiService = ConnectionsApiService();
  ConnectivityService connectivityService = ConnectivityService();
  PushNotificationsService pushNotificationsService = PushNotificationsService();
  IntercomService intercomService = IntercomService();
  UtilsService utilsService = UtilsService();
  ThemeService themeService = ThemeService();
  ThemeValueParserService themeValueParserService = ThemeValueParserService();
  MediaService mediaService = MediaService();
  ShareService shareService = ShareService();
  BottomSheetService bottomSheetService = BottomSheetService();
  DialogService dialogService = DialogService();
  DatePickerService datePickerService = DatePickerService();
  HashtagsApiService hashtagsApiService = HashtagsApiService();
  TextAutocompletionService textAccountAutocompletionService = TextAutocompletionService();
  LinkPreviewService linkPreviewService = LinkPreviewService();
  PermissionsService permissionService = PermissionsService();
  ConnectionsCirclesApiService connectionsCirclesApiService = ConnectionsCirclesApiService();

  NavigationService navigationService = NavigationService();
  PostsApiService postsApiService = PostsApiService();

  NotesApiService notesApiService = NotesApiService();
  CategoriesApiService categoriesApiService = CategoriesApiService();
  MoodsApiService moodsApiService = MoodsApiService();
  ColorRangesApiService colorRangesApiService = ColorRangesApiService();

  StoriesApiService storiesApiService = StoriesApiService();

  DraftService draftService = DraftService();
  LocalizationService localizationService;
  SentryClient sentryClient;

  @override
  void initState() {
    super.initState();
    initAsyncState();

    userPreferencesService.setStorageService(storageService);
    userPreferencesService.setConnectivityService(connectivityService);
    httpService.setUtilsService(utilsService);
    connectionsApiService.setHttpService(httpService);
    connectionsCirclesApiService.setHttpService(httpService);
    authApiService.setHttpService(httpService);
    authApiService.setStringTemplateService(stringTemplateService);
    connectionsCirclesApiService.setStringTemplateService(stringTemplateService);
    createAccountBloc.setAuthApiService(authApiService);
    createAccountBloc.setUserService(userService);


    //createStoryBloc.setUserService(userService);

    userService.setAuthApiService(authApiService);
    userService.setPushNotificationsService(pushNotificationsService);
    userService.setIntercomService(intercomService);
    userService.setHttpieService(httpService);
    userService.setStorageService(storageService);
    userService.setConnectionsApiService(connectionsApiService);
    userService.setConnectionsCirclesApiService(connectionsCirclesApiService);
    userService.setNotificationsApiService(notificationsApiService);
    userService.setDevicesApiService(devicesApiService);
    userService.setCreateAccountBlocService(createAccountBloc);

    userService.setHashtagsApiService(hashtagsApiService);

    userService.setNotesApiService(notesApiService);

    userService.setCategoriesApiService(categoriesApiService);
    userService.setMoodsApiService(moodsApiService);
    userService.setColorRangesApiService(colorRangesApiService);

    userService.setStoriesApiServiceService(storiesApiService);
    userService.setDraftService(draftService);

    notificationsApiService.setHttpService(httpService);
    notificationsApiService.setStringTemplateService(stringTemplateService);
    devicesApiService.setHttpService(httpService);
    devicesApiService.setStringTemplateService(stringTemplateService);
    validationService.setAuthApiService(authApiService);
    validationService.setUtilsService(utilsService);
    validationService.setConnectionsCirclesApiService(connectionsCirclesApiService);

    themeService.setStorageService(storageService);
    themeService.setUtilsService(utilsService);
    mediaService.setValidationService(validationService);
    mediaService.setBottomSheetService(bottomSheetService);
    mediaService.setPermissionsService(permissionService);
    mediaService.setUtilsService(utilsService);
    pushNotificationsService.setUserService(userService);
    pushNotificationsService.setStorageService(storageService);
    intercomService.setUserService(userService);
    shareService.setMediaService(mediaService);
    shareService.setToastService(toastService);
    shareService.setValidationService(validationService);
    dialogService.setThemeService(themeService);
    dialogService.setThemeValueParserService(themeValueParserService);
    hashtagsApiService.setHttpieService(httpService);
    hashtagsApiService.setStringTemplateService(stringTemplateService);
    linkPreviewService.setHttpieService(httpService);
    linkPreviewService.setUtilsService(utilsService);
    linkPreviewService.setValidationService(validationService);
    permissionService.setToastService(toastService);

    notesApiService.setHttpieService(httpService);
    notesApiService.setStringTemplateService(stringTemplateService);

    categoriesApiService.setHttpieService(httpService);
    moodsApiService.setHttpieService(httpService);
    colorRangesApiService.setHttpieService(httpService);

    //userService.setCreateStoryBlocService(createStoryBloc);
    storiesApiService.setHttpieService(httpService);

    userService.setPostsApiService(postsApiService);

    postsApiService.setHttpieService(httpService);
    postsApiService.setStringTemplateService(stringTemplateService);

  }

  void initAsyncState() async {
    Environment environment =
        await EnvironmentLoader(environmentPath: ".env.json").load();
    httpService.setMagicHeader(
        environment.magicHeaderName, environment.magicHeaderValue);
    httpService
        .setProxy(await ProxySettings.findProxy(Uri.parse(environment.apiUrl)));
    authApiService.setApiURL(environment.apiUrl);
    connectionsApiService.setApiURL(environment.apiUrl);
    connectionsCirclesApiService.setApiURL(environment.apiUrl);
    notificationsApiService.setApiURL(environment.apiUrl);
    devicesApiService.setApiURL(environment.apiUrl);
    hashtagsApiService.setApiURL(environment.apiUrl);

    notesApiService.setApiURL(environment.apiUrl);

    categoriesApiService.setApiURL(environment.apiUrl);
    moodsApiService.setApiURL(environment.apiUrl);
    colorRangesApiService.setApiURL(environment.apiUrl);

    storiesApiService.setApiURL(environment.apiUrl);

    postsApiService.setApiURL(environment.apiUrl);

    intercomService.bootstrap(
        iosApiKey: environment.intercomIosKey,
        androidApiKey: environment.intercomAndroidKey,
        appId: environment.intercomAppId);
    sentryClient = SentryClient(dsn: environment.sentryDsn);
    await connectivityService.bootstrap();
    userPreferencesService.bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return new _OneFProvider(
      data: this,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    super.dispose();
    pushNotificationsService.dispose();
    connectivityService.dispose();
    userPreferencesService.dispose();
  }

  setLocalizationService(LocalizationService newLocalizationService) {
    localizationService = newLocalizationService;
    createAccountBloc.setLocalizationService(localizationService);
    //createStoryBloc.setLocalizationService(localizationService);
    httpService.setLocalizationService(localizationService);
    userService.setLocalizationsService(localizationService);
    modalService.setLocalizationService(localizationService);
    userPreferencesService.setLocalizationService(localizationService);
    shareService.setLocalizationService(localizationService);
    mediaService.setLocalizationService(localizationService);
    permissionService.setLocalizationService(localizationService);
  }

  setValidationService(ValidationService newValidationService) {
    validationService = newValidationService;
  }
}

class _OneFProvider extends InheritedWidget {
  final OneFProviderState data;

  _OneFProvider({Key key, this.data, Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(_OneFProvider old) {
    return true;
  }
}
