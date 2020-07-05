import 'dart:async';

import 'package:flutter/material.dart';
import 'package:onef/models/stories_list.dart';
import 'package:onef/models/user.dart';
import 'package:onef/pages/home/lib/poppable_page_controller.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/bottom_sheet.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/modal_service.dart';
import 'package:onef/services/theme.dart';
import 'package:onef/services/theme_value_parser.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/drawable.dart';
import 'package:onef/widgets/story/background.dart';
import 'package:onef/widgets/story/close.dart';
import 'package:onef/widgets/story/story_content.dart';

class OFEditStoryPage extends StatefulWidget {

  OFEditStoryPage();
  @override
  State<OFEditStoryPage> createState() {
    return OFEditStoryPageState();
  }
}

class OFEditStoryPageState extends State<OFEditStoryPage> {
  UserService _userService;
  ModalService _modalService;
  BottomSheetService _bottomSheetService;
  ToastService _toastService;
  LocalizationService _localizationService;
  ThemeService _themeService;
  ThemeValueParserService _themeValueParserService;

  StoriesList _storiesList;
  bool _refreshInProgress;
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;

  StreamSubscription _loggedInUserChangeSubscription;
  bool _needsBootstrap;
  bool _loggedInUserBootstrapped;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _loggedInUserBootstrapped = false;

    _refreshInProgress = false;
    _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  }

  @override
  void dispose() {
    super.dispose();
    _loggedInUserChangeSubscription.cancel();
  }

  void _bootstrap() async {
    _loggedInUserChangeSubscription =
        _userService.loggedInUserChange.listen(_onLoggedInUserChange);
  }

  void _onLoggedInUserChange(User newUser) async {
    if (newUser == null) return;

    setState(() {
      _loggedInUserBootstrapped = true;
      _loggedInUserChangeSubscription.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;

    if (_needsBootstrap) {
      var provider = OneFProvider.of(context);
      _userService = provider.userService;
      _bottomSheetService = provider.bottomSheetService;
      _modalService = provider.modalService;
      _toastService = provider.toastService;
      _localizationService = provider.localizationService;
      _themeService = provider.themeService;
      _themeValueParserService = provider.themeValueParserService;
      _bootstrap();

      //_refreshTaskList();
      _needsBootstrap = false;
    }

    return RefreshIndicator(
      onRefresh: _refreshStoriesList,
      key: _refreshIndicatorKey,
      child: Scaffold(
        body: Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            OFBackground(),
            OFStoryContent(),
            OFClose(onPressed: () => Navigator.pop(context)),
          ],
        ),
      ));
  }


  Future<void> _refreshStoriesList() async {
    debugPrint('Refreshing task list');
    //_setRefreshInProgress(true);
    try {
      //_getTaskList();
    } catch (error) {
      _onError(error);
    } finally {
      //_setRefreshInProgress(false);
    }
  }

  Future refresh() {
    //return _notesStreamController.refreshNotes();
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage, context: context);
    } else {
      _toastService.error(
          message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }
}

class OFEditStoryPageController extends PoppablePageController {
  OFEditStoryPageState _state;

  void attach({@required BuildContext context, OFEditStoryPageState state}) {
    super.attach(context: context);
    _state = state;
  }

  Future<void> refresh() {
    return _state.refresh();
  }
}
