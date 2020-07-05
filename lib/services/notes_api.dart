import 'package:onef/services/httpie.dart';
import 'package:onef/services/string_template.dart';

class NotesApiService {
  HttpieService _httpService;
  StringTemplateService _stringTemplateService;

  String apiURL;

  static const GET_NOTES_PATH = 'api/notes/';

  void setHttpieService(HttpieService httpService) {
    _httpService = httpService;
  }

  void setStringTemplateService(StringTemplateService stringTemplateService) {
    _stringTemplateService = stringTemplateService;
  }

  void setApiURL(String newApiURL) {
    apiURL = newApiURL;
  }

  Future<HttpieResponse> getNotes(
      {int maxId,
      int minId,
      int count,
      String username,
      bool authenticatedRequest = true}) {
    Map<String, dynamic> queryParams = {};
    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    if (minId != null) queryParams['min_id'] = minId;

    return _httpService.get('$apiURL$GET_NOTES_PATH',
        queryParameters: queryParams,
        appendAuthorizationToken: authenticatedRequest);
  }

  String _makeApiUrl(String string) {
    return '$apiURL$string';
  }
}
