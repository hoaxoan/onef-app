import 'dart:math';

import 'package:onef/models/theme.dart';
import 'package:onef/services/storage.dart';
import 'package:onef/services/utils_service.dart';
import 'package:rxdart/rxdart.dart';

class ThemeService {
  UtilsService _utilsService;

  Stream<OFTheme> get themeChange => _themeChangeSubject.stream;
  final _themeChangeSubject = ReplaySubject<OFTheme>(maxSize: 1);

  Random random = new Random();

  OFTheme _activeTheme;

  OFStorage _storage;

  List<OFTheme> _themes = [
    OFTheme(
        id: 1,
        name: 'White Gold',
        primaryTextColor: '#505050',
        secondaryTextColor: '#676767',
        primaryColor: '#ffffff',
        primaryAccentColor: '#e9a039,#f0c569',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview:
            'assets/images/theme-previews/theme-preview-white-gold.png'),
    OFTheme(
        id: 2,
        name: 'Dark Gold',
        primaryTextColor: '#ffffff',
        secondaryTextColor: '#b3b3b3',
        primaryColor: '#000000',
        primaryAccentColor: '#e9a039,#f0c569',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview:
            'assets/images/theme-previews/theme-preview-dark-gold.png'),
    OFTheme(
        id: 3,
        name: 'Light',
        primaryTextColor: '#505050',
        secondaryTextColor: '#676767',
        primaryColor: '#ffffff',
        primaryAccentColor: '#ffdd00,#f93476',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview: 'assets/images/theme-previews/theme-preview-white.png'),
    OFTheme(
        id: 4,
        name: 'Dark',
        primaryTextColor: '#ffffff',
        secondaryTextColor: '#b3b3b3',
        primaryColor: '#000000',
        primaryAccentColor: '#ffdd00,#f93476',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview: 'assets/images/theme-previews/theme-preview-dark.png'),
    OFTheme(
        id: 5,
        name: 'Light Blue',
        primaryAccentColor: '#045DE9, #7bd1e0',
        primaryTextColor: '#505050',
        secondaryTextColor: '#676767',
        primaryColor: '#ffffff',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview:
            'assets/images/theme-previews/theme-preview-light-blue.png'),
    OFTheme(
        id: 6,
        name: 'Space Blue',
        primaryTextColor: '#ffffff',
        secondaryTextColor: '#b3b3b3',
        primaryColor: '#232323',
        primaryAccentColor: '#045DE9, #7bd1e0',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview:
            'assets/images/theme-previews/theme-preview-space-blue.png'),
    OFTheme(
        id: 7,
        name: 'Light Rose',
        primaryAccentColor: '#D4418E, #ff84af',
        primaryTextColor: '#505050',
        secondaryTextColor: '#676767',
        primaryColor: '#ffffff',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview:
            'assets/images/theme-previews/theme-preview-light-rose.png'),
    OFTheme(
        id: 8,
        name: 'Space Rose',
        primaryTextColor: '#ffffff',
        secondaryTextColor: '#b3b3b3',
        primaryColor: '#232323',
        primaryAccentColor: '#D4418E, #ff84af',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview:
            'assets/images/theme-previews/theme-preview-space-rose.png'),
    OFTheme(
        id: 9,
        name: 'Light Royale',
        primaryAccentColor: '#5F0A87, #B621FE',
        primaryTextColor: '#505050',
        secondaryTextColor: '#676767',
        primaryColor: '#ffffff',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview:
            'assets/images/theme-previews/theme-preview-light-royale.png'),
    OFTheme(
        id: 10,
        name: 'Space Royale',
        primaryTextColor: '#ffffff',
        secondaryTextColor: '#b3b3b3',
        primaryColor: '#232323',
        primaryAccentColor: '#5F0A87, #B621FE',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview:
            'assets/images/theme-previews/theme-preview-space-royale.png'),
    OFTheme(
        id: 11,
        name: 'Light Cinnabar',
        primaryAccentColor: '#A71D31, #F53844',
        primaryTextColor: '#505050',
        secondaryTextColor: '#676767',
        primaryColor: '#ffffff',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview:
            'assets/images/theme-previews/theme-preview-light-cinnabar.png'),
    OFTheme(
        id: 12,
        name: 'Space Cinnabar',
        primaryTextColor: '#ffffff',
        secondaryTextColor: '#b3b3b3',
        primaryColor: '#232323',
        primaryAccentColor: '#A71D31, #F53844',
        successColor: '#7ED321',
        successColorAccent: '#ffffff',
        dangerColor: '#FF3860',
        dangerColorAccent: '#ffffff',
        themePreview:
            'assets/images/theme-previews/theme-preview-space-cinnabar.png'),
  ];

  ThemeService() {
    _setActiveTheme(_themes[2]);
  }

  void setStorageService(StorageService storageService) {
    _storage = storageService.getSystemPreferencesStorage(namespace: 'theme');
    this._bootstrap();
  }

  void setUtilsService(UtilsService utilsService) {
    _utilsService = utilsService;
  }

  void setActiveTheme(OFTheme theme) {
    _setActiveTheme(theme);
    _storeActiveThemeId(theme.id);
  }

  void _bootstrap() async {
    int activeThemeId = await _getStoredActiveThemeId();
    if (activeThemeId != null) {
      OFTheme activeTheme = await _getThemeWithId(activeThemeId);
      _setActiveTheme(activeTheme);
    }
  }

  void _setActiveTheme(OFTheme theme) {
    _activeTheme = theme;
    _themeChangeSubject.add(theme);
  }

  void _storeActiveThemeId(int themeId) {
    if (_storage != null) _storage.set('activeThemeId', themeId.toString());
  }

  Future<OFTheme> _getThemeWithId(int id) async {
    return _themes.firstWhere((OFTheme theme) {
      return theme.id == id;
    });
  }

  Future<int> _getStoredActiveThemeId() async {
    String activeThemeId = await _storage.get('activeThemeId');
    return activeThemeId != null ? int.parse(activeThemeId) : null;
  }

  OFTheme getActiveTheme() {
    return _activeTheme;
  }

  bool isActiveTheme(OFTheme theme) {
    return theme.id == this.getActiveTheme().id;
  }

  List<OFTheme> getCuratedThemes() {
    return _themes.toList();
  }

  String generateRandomHexColor() {
    int length = 6;
    String chars = '0123456789ABCDEF';
    String hex = '#';
    while (length-- > 0) hex += chars[(random.nextInt(16)) | 0];
    return hex;
  }
}
