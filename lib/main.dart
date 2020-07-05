import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:onef/delegates/es_es_localizations_delegate.dart';
import 'package:onef/delegates/localization_delegate.dart';
import 'package:onef/pages/auth/create_account/create_account.dart';
import 'package:onef/pages/auth/login.dart';
import 'package:onef/pages/auth/splash.dart';
import 'package:onef/pages/home/home.dart';
import 'package:onef/pages/home/pages/note/note_detail_page.dart';
import 'package:onef/plugins/desktop/error-reporting.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/translation/constants.dart';
import 'package:sentry/sentry.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class OneFApp extends StatefulWidget {
  final oneFProviderKey = new GlobalKey<OneFProviderState>();

  @override
  _OneFAppState createState() => _OneFAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _OneFAppState state =
        context.ancestorStateOfType(TypeMatcher<_OneFAppState>());

    state.setState(() {
      state.locale = newLocale;
    });
  }
}

class _OneFAppState extends State<OneFApp> {
  Locale locale;
  bool _needsBootstrap;

  static const MAX_NETWORK_IMAGE_CACHE_MB = 200;
  static const MAX_NETWORK_IMAGE_CACHE_ENTRIES = 1000;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
  }

  void bootstrap() {
    DiskCache().maxEntries = MAX_NETWORK_IMAGE_CACHE_ENTRIES;
    //DiskCache().maxSizeBytes = MAX_NETWORK_IMAGE_CACHE_MB * 1000000; // 200mb
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      bootstrap();
      Firestore.instance.settings(persistenceEnabled: true);
      _needsBootstrap = false;
    }

    var textTheme = _defaultTextTheme();
    return OneFProvider(
      key: widget.oneFProviderKey,
      child: MaterialApp(
        navigatorObservers: [routeObserver],
        locale: this.locale,
        debugShowCheckedModeBanner: false,
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          // if no deviceLocale use english
          if (deviceLocale == null) {
            this.locale = Locale('en', 'US');
            return this.locale;
          }
          // initialise locale from device
          if (deviceLocale != null &&
              supportedLanguages.contains(deviceLocale.languageCode) &&
              this.locale == null) {
            Locale supportedMatchedLocale = supportedLocales.firstWhere(
                (Locale locale) =>
                    locale.languageCode == deviceLocale.languageCode);
            this.locale = supportedMatchedLocale;
          } else if (this.locale == null) {
            print(
                'Locale ${deviceLocale.languageCode} not supported, defaulting to en');
            this.locale = Locale('en', 'US');
          }
          return this.locale;
        },
        title: 'OneF',
        supportedLocales: supportedLocales,
        localizationsDelegates: [
          const LocalizationServiceDelegate(),
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          const MaterialLocalizationEsESDelegate(),
          const CupertinoLocalizationEsESDelegate()
        ],
        theme: new ThemeData(
            buttonTheme: ButtonThemeData(
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(2.0))),
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
            // counter didn't reset back to zero; the application is not restarted.
            primarySwatch: Colors.grey,
            fontFamily: 'NunitoSans',
            textTheme: textTheme,
            primaryTextTheme: textTheme,
            accentTextTheme: textTheme),
        routes: {
          '/': (BuildContext context) {
            bootstrapProviderInContext(context);
            return OFHomePage();
          },
          '/auth': (BuildContext context) {
            bootstrapProviderInContext(context);
            return OFAuthSplashPage();
          },
          '/auth/login': (BuildContext context) {
            bootstrapProviderInContext(context);
            return OFAuthLoginPage();
          },
          '/auth/token': (BuildContext context) {
            bootstrapProviderInContext(context);
            return OFAuthCreateAccountPage();
          },
        },
        //onGenerateRoute: _generateRoute,
      ),
    );
  }

  void bootstrapProviderInContext(BuildContext context) {
    var provider = OneFProvider.of(context);
    var localizationService = LocalizationService.of(context);
    if (this.locale.languageCode !=
        localizationService.getLocale().languageCode) {
      Future.delayed(Duration(milliseconds: 0), () {
        OneFApp.setLocale(context, this.locale);
      });
    }
    provider.setLocalizationService(localizationService);
    provider.validationService.setLocalizationService(localizationService);
  }
}

void _setPlatformOverrideForDesktop() {
  TargetPlatform targetPlatform;
  if (Platform.isMacOS) {
    targetPlatform = TargetPlatform.iOS;
  } else if (Platform.isLinux || Platform.isWindows) {
    targetPlatform = TargetPlatform.android;
  }
  if (targetPlatform != null) {
    debugDefaultTargetPlatformOverride = targetPlatform;
  }
}

Future<Null> main() async {
  OneFApp app = OneFApp();

// Run the whole app in a zone to capture all uncaught errors.
  runZonedGuarded(() => runApp(app), (Object error, StackTrace stackTrace) {
    if (isInDebugMode) {
      print(error);
      print(stackTrace);
      print('In dev mode. Not sending report to Sentry.io.');
      return;
    }

    SentryClient sentryClient =
        app.oneFProviderKey.currentState.sentryClient;

    try {
      sentryClient.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      print('Error sent to sentry.io: $error');
    } catch (e) {
      print('Sending report to sentry.io failed: $e');
      print('Original error: $error');
    }
  });
}

/// Reports [error] along with its [stackTrace] to Sentry.io.
Future<Null> _reportError(
    dynamic error, dynamic stackTrace, SentryClient sentryClient) async {
  print('Caught error: $error');

  // Errors thrown in development mode are unlikely to be interesting. You can
  // check if you are running in dev mode using an assertion and omit sending
  // the report.
  if (isInDebugMode) {
    print(stackTrace);
    print('In dev mode. Not sending report to Sentry.io.');
    return;
  }

  print('Reporting to Sentry.io...');
  final SentryResponse response = await sentryClient.captureException(
    exception: error,
    stackTrace: stackTrace,
  );

  if (response.isSuccessful) {
    print('Success! Event ID: ${response.eventId}');
  } else {
    print('Failed to report to Sentry.io: ${response.error}');
  }
}

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

bool get isOnDesktop {
  return Platform.isLinux || Platform.isMacOS || Platform.isWindows;
}

TextTheme _defaultTextTheme() {
  return new TextTheme();
}
