import 'package:onef/models/category.dart';
import 'package:onef/models/mood.dart';
import 'package:onef/models/story.dart';
import 'package:onef/models/user.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/string_template.dart';

class StoriesApiService {
  HttpieService _httpService;
  StringTemplateService _stringTemplateService;

  String apiURL;

  static const GET_STORIES_PATH = 'story/stories';
  static const CREATE_STORY_PATH = 'story/story';

  void setHttpieService(HttpieService httpService) {
    _httpService = httpService;
  }

  void setStringTemplateService(StringTemplateService stringTemplateService) {
    _stringTemplateService = stringTemplateService;
  }

  void setApiURL(String newApiURL) {
    apiURL = newApiURL;
  }
  String _makeApiUrl(String string) {
    return '$apiURL$string';
  }

  Future<HttpieResponse> getStories(
      {int maxId,
        int count,
        String username,
        bool authenticatedRequest = true}) {
    Map<String, dynamic> queryParams = {};

    if (count != null) queryParams['count'] = count;

    if (maxId != null) queryParams['max_id'] = maxId;

    if (username != null) queryParams['username'] = username;

    return _httpService.get(_makeApiUrl(GET_STORIES_PATH),
        queryParameters: queryParams,
        appendAuthorizationToken: authenticatedRequest);
  }

  Future<HttpieResponse> createStory({String title, Category category, Mood mood, User owner}) {
    var story = new Story(title: title, category: category, mood: mood, owner:  owner);
    return _httpService.postJSON(_makeApiUrl(CREATE_STORY_PATH), body: story.toJson(), appendAuthorizationToken: true);
  }

}
