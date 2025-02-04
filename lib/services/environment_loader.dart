import 'dart:async' show Future;
import 'dart:convert' show json;

import 'package:flutter/services.dart' show rootBundle;

class EnvironmentLoader {
  final String environmentPath;

  EnvironmentLoader({this.environmentPath});

  Future<Environment> load() {
    return rootBundle.loadStructuredData<Environment>(this.environmentPath,
        (jsonStr) async {
      final environmentLoader = Environment.fromJson(json.decode(jsonStr));
      return environmentLoader;
    });
  }
}

class Environment {
  final String apiUrl;
  final String magicHeaderName;
  final String magicHeaderValue;
  final String intercomIosKey;
  final String intercomAndroidKey;
  final String intercomAppId;
  final String sentryDsn;
  final String oneFSocialApiUrl;

  const Environment(
      {this.sentryDsn = '',
      this.oneFSocialApiUrl = '',
      this.apiUrl = '',
      this.magicHeaderName = '',
      this.magicHeaderValue = '',
      this.intercomAndroidKey = '',
      this.intercomAppId = '',
      this.intercomIosKey = ''});

  factory Environment.fromJson(Map<String, dynamic> jsonMap) {
    return new Environment(
      apiUrl: jsonMap["API_URL"],
      magicHeaderName: jsonMap["MAGIC_HEADER_NAME"],
      magicHeaderValue: jsonMap["MAGIC_HEADER_VALUE"],
      intercomAppId: jsonMap["INTERCOM_APP_ID"],
      intercomIosKey: jsonMap["INTERCOM_IOS_KEY"],
      intercomAndroidKey: jsonMap["INTERCOM_ANDROID_KEY"],
      sentryDsn: jsonMap["SENTRY_DSN"],
      oneFSocialApiUrl: jsonMap["ONEF_SOCIAL_API_URL"],
    );
  }
}
