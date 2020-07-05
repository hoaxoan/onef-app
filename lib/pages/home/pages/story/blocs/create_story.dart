import 'package:onef/models/category.dart';
import 'package:onef/models/mood.dart';
import 'package:onef/models/story.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/user.dart';
import 'package:rxdart/rxdart.dart';

class CreateStoryBloc {
  LocalizationService _localizationService;
  UserService _userService;

  void setLocalizationService(LocalizationService localizationService) {
    _localizationService = localizationService;
  }

  void setUserService(UserService userService) {
    _userService = userService;
  }

  // Serves as a snapshot to the data
  final storyData = StoryData();

  final _currentPageSubject = BehaviorSubject<int>();
  final _titleSubject = BehaviorSubject<String>();
  final _categorySubject = BehaviorSubject<Category>();
  final _moodSubject = BehaviorSubject<Mood>();

  // Create account begins

  Stream<bool> get createStoryInProgress => _createStoryInProgressSubject.stream;
  final _createStoryInProgressSubject = ReplaySubject<bool>();

  Stream<String> get createStoryErrorFeedback => _createStoryErrorFeedbackSubject.stream;
  final _createStoryErrorFeedbackSubject = ReplaySubject<String>();

  // Create account ends

  CreateAccountBloc() {
    _currentPageSubject.stream.listen(_onCurrentPageChange);
    _titleSubject.stream.listen(_onTitleChange);
    _categorySubject.stream.listen(_onCategoryChange);
    _moodSubject.listen(_onMoodChange);
  }

  void dispose() {
    _currentPageSubject.close();
    _titleSubject.close();
    _categorySubject.close();
    _moodSubject.close();
  }


  // CurrentPage begins

  bool hasCurrentPage() {
    return storyData.currentPage != null;
  }

  int getCurrentPage() {
    if (storyData.currentPage == null)
      return 0;

    return storyData.currentPage;
  }

  void setCurrentPage(int currentPage) {
    _currentPageSubject.add(currentPage);
    storyData.currentPage = currentPage;
  }

  void _onCurrentPageChange(int currentPage) {
    if (currentPage == null) return;
    storyData.currentPage = currentPage;
  }

  void _clearCurrentPage() {
    storyData.currentPage = 0;
  }
  // CurrentPage ends

  // Title begins
  bool hasTitle() {
    return storyData.title != null;
  }

  String getTitle() {
    return storyData.title;
  }

  void setTitle(String title) {
    _titleSubject.add(title);
    storyData.title = title;
  }

  void _onTitleChange(String title) {
    if (title == null) return;
    storyData.title = title;
  }

  void _clearTitle() {
    storyData.title = null;
  }
  // Title ends

  // Category begins
  bool hasCategory() {
    return storyData.category != null;
  }

  Category getCategory() {
    return storyData.category;
  }

  void setCategory(Category category) {
    _categorySubject.add(category);
    storyData.category = category;
  }

  void _onCategoryChange(Category category) {
    if (category == null) return;
    storyData.category = category;
  }

  void _clearCategory() {
    storyData.category = null;
  }
  // Title ends

  // Mood begins
  bool hasMood() {
    return storyData.mood != null;
  }

  Mood getMood() {
    return storyData.mood;
  }

  void setMood(Mood mood) {
    _moodSubject.add(mood);
    storyData.mood = mood;
  }

  void _onMoodChange(Mood mood) {
    if (mood == null) return;
    storyData.mood = mood;
  }

  void _clearMood() {
    storyData.mood = null;
  }
  // MoodCode ends

  // create story
  Future<bool> createStory() async {
    _clearCreateStory();

    _createStoryInProgressSubject.add(true);

    var storyWasCreated = false;

    try {
      Story story = await _userService.createStory(
          title: storyData.title,
          category: storyData.category,
          mood: storyData.mood);

      storyWasCreated = true;
    } catch (error) {
      if (error is HttpieConnectionRefusedError) {
        _onCreateStoryValidationError(error.toHumanReadableMessage());
      } else if (error is HttpieRequestError) {
        String errorMessage = await error.toHumanReadableMessage();
        _onCreateStoryValidationError(errorMessage);
      } else {
        _onCreateStoryValidationError('Unknown error');
        rethrow;
      }
    }

    return storyWasCreated;
  }

  void _onCreateStoryValidationError(String errorMessage) {
    _createStoryErrorFeedbackSubject.add(errorMessage);
  }

  void _clearCreateStory() {
    _createStoryInProgressSubject.add(null);
  }

  void clearAll() {
    _clearCurrentPage();
    _clearCreateStory();
    _clearTitle();
    _clearCategory();
    _clearMood();
  }

}


class StoryData {
  int currentPage;
  String title;
  String description;
  String note;
  bool isFavorite;
  Category category;
  Mood mood;
}
