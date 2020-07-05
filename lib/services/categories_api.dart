import 'package:onef/services/httpie.dart';

class CategoriesApiService {
  HttpieService _httpService;

  String apiURL;

  static const getCategoriesPath = 'common/categories';

  void setHttpieService(HttpieService httpService) {
    _httpService = httpService;
  }

  void setApiURL(String newApiURL) {
    apiURL = newApiURL;
  }

  Future<HttpieResponse> getCategories() {
    String url = _makeApiUrl(getCategoriesPath);
    return _httpService.get(url, appendAuthorizationToken: true);
  }

  String _makeApiUrl(String string) {
    return '$apiURL$string';
  }
}
