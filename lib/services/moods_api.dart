import 'dart:convert';

import 'package:onef/models/moods_list.dart';
import 'package:onef/services/httpie.dart';

class MoodsApiService {
  HttpieService _httpService;

  String apiURL;

  static const getMoodsPath = 'common/moods';

  void setHttpieService(HttpieService httpService) {
    _httpService = httpService;
  }

  void setApiURL(String newApiURL) {
    apiURL = newApiURL;
  }

  Future<HttpieResponse> getMoods() {
    String url = _makeApiUrl(getMoodsPath);
    return _httpService.get(url, appendAuthorizationToken: true);
  }

  String _makeApiUrl(String string) {
    return '$apiURL$string';
  }

  void _checkResponseIsOk(HttpieBaseResponse response) {
    if (response.isOk()) return;
    throw HttpieRequestError(response);
  }

}
