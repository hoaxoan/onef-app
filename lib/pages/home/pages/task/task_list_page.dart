import 'dart:async';

import 'package:flutter/material.dart';
import 'package:onef/models/task_list.dart';
import 'package:onef/models/task_widget.dart';
import 'package:onef/models/user.dart';
import 'package:onef/pages/home/lib/poppable_page_controller.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/theme.dart';
import 'package:onef/services/theme_value_parser.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/fields/text_field.dart';
import 'package:onef/widgets/page_scaffold.dart';
import 'package:onef/widgets/search_bar.dart';
import 'package:onef/widgets/task/task_list.dart';
import 'package:onef/widgets/task/task_widget.dart';
import 'package:onef/widgets/theming/primary_color_container.dart';
import 'package:onef/widgets/theming/text.dart';

class OFTaskListPage extends StatefulWidget {
  final OFTaskListPageController controller;

  OFTaskListPage({
    @required this.controller,
  });

  @override
  OFTaskListPageState createState() => OFTaskListPageState();
}

class OFTaskListPageState extends State<OFTaskListPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  UserService _userService;
  ToastService _toastService;
  LocalizationService _localizationService;
  ThemeService _themeService;
  ThemeValueParserService _themeValueParserService;

  List<TaskList> _taskLists;
  List<TaskWidget> _taskWidgets;
  bool _refreshInProgress;
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;

  StreamSubscription _loggedInUserChangeSubscription;
  bool _needsBootstrap;
  bool _loggedInUserBootstrapped;

  double _extraPaddingForSlidableSection;
  static const double HEIGHT_SEARCH_BAR = 76.0;

  @override
  void initState() {
    super.initState();
    widget.controller.attach(context: context, state: this);
    _needsBootstrap = true;
    _loggedInUserBootstrapped = false;

    _taskLists = [];
    _taskWidgets = [];

    _refreshInProgress = false;
    _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  }

  @override
  void dispose() {
    super.dispose();
    _loggedInUserChangeSubscription.cancel();
  }

  Future refresh() {}

  void _onLoggedInUserChange(User newUser) async {
    if (newUser == null) return;

    setState(() {
      _loggedInUserBootstrapped = true;
      _loggedInUserChangeSubscription.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OneFProvider.of(context);
      _userService = provider.userService;
      _toastService = provider.toastService;
      _localizationService = provider.localizationService;
      _themeService = provider.themeService;
      _themeValueParserService = provider.themeValueParserService;
      _bootstrap();
      _needsBootstrap = false;
    }

    if (_extraPaddingForSlidableSection == null)
      _extraPaddingForSlidableSection = _getExtraPaddingForSlidableSection();

    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final crossAxisChildCount = isPortrait ? 2 : 4;

    return RefreshIndicator(
      onRefresh: _refreshTaskList,
      key: _refreshIndicatorKey,
      displacement: 80,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        resizeToAvoidBottomPadding: true,
        body: Container(
            child: Padding(
                padding: EdgeInsets.only(top: devicePadding.top),
                child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.only(top: 6.0),
                                  child: Container(
                                      child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 10.0, top: 0.0, right: 10.0),
                                    child: Card(
                                        elevation: 3.0,
                                        margin: EdgeInsets.only(top: 10.0),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(24.0))),
                                        color: Colors.white,
                                        child: Row(children: <Widget>[
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Stack(
                                            alignment: Alignment(
                                              2.4,
                                              -1.4,
                                            ),
                                            children: <Widget>[
                                              GestureDetector(
                                                child: Icon(
                                                  Icons.search,
                                                  color: Colors.black54,
                                                ),
                                                onTap: () {},
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Expanded(
                                              child: OFTextField(
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: _localizationService
                                                    .post__search_circles),
                                            style: TextStyle(
                                              fontSize: 18.0,
                                            ),
                                          )),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                        ])),
                                  ))),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 22.0,
                                  left: 20,
                                  right: 20,
                                ),
                                child: _taskWidgets.isEmpty &&
                                        !_refreshInProgress
                                    ? Container()
                                    : GridView.builder(
                                        shrinkWrap: true,
                                        padding:
                                            const EdgeInsets.only(bottom: 4.0),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisChildCount,
                                          childAspectRatio: 1.75,
                                        ),
                                        itemCount: _taskWidgets.length,
                                        itemBuilder: _buildTaskWidget,
                                      ),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(
                                    top: 16.0,
                                    bottom: 16.0,
                                    left: 20,
                                    right: 20,
                                  ),
                                  child: OFText(
                                    _localizationService
                                        .user__follow_lists_title,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500),
                                  )),
                            ] +
                            _buildTaskList(context))))),
        floatingActionButton: Container(
            padding: EdgeInsets.only(bottom: 12.0),
            child: FloatingActionButton.extended(
              elevation: 4.0,
              backgroundColor: Color.fromRGBO(89, 157, 166, 1),
              icon: const Icon(Icons.add),
              label: Text(_localizationService.task__new_list, maxLines: 1),
              onPressed: () async {},
            )),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      ),
    );
  }

  void _bootstrap() {
    _loggedInUserChangeSubscription =
        _userService.loggedInUserChange.listen(_onLoggedInUserChange);

    Future.delayed(
        Duration(
          milliseconds: 0,
        ), () {
      if (_refreshIndicatorKey.currentState != null) {
        _refreshIndicatorKey.currentState.show();
      }
    });
  }

  double _getExtraPaddingForSlidableSection() {
    return 34.0;
  }

  Widget _createSearchBar() {
    MediaQueryData existingMediaQuery = MediaQuery.of(context);
    return Positioned(
        left: 0,
        top: 0,
        height: HEIGHT_SEARCH_BAR + _extraPaddingForSlidableSection,
        width: existingMediaQuery.size.width,
        child: OFCupertinoPageScaffold(
          backgroundColor: Colors.transparent,
          child: OFPrimaryColorContainer(
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  OFSearchBar(
                    onSearch: _onSearch,
                    hintText: _localizationService.user_search__search_text,
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void _onSearch(String query) {}

  List<Widget> _buildTaskList(BuildContext context) {
    return _taskLists
        .map<Widget>((TaskList taskList) => OFTaskList(
              taskList: taskList,
              onView: _onViewTaskList,
            ))
        .toList();
  }

  void _onViewTaskList(TaskList taskList) {}

  Widget _buildTaskWidget(BuildContext context, index) {
    TaskWidget taskWidget = _taskWidgets[index];
    return OFTaskWidget(
      taskWidget: taskWidget,
      onView: _onViewTaskWidget,
    );
  }

  void _onViewTaskWidget(TaskWidget taskWidget) {}

  Future<void> _refreshTaskList() async {
    debugPrint('Refreshing task list');
    _setRefreshInProgress(true);
    try {
      _getTaskWidgets();
      _getTaskList();
    } catch (error) {
      _onError(error);
    } finally {
      _setRefreshInProgress(false);
    }
  }

  Future<void> _getTaskList() async {
    debugPrint('get task list');
    try {
      List<TaskList> taskLists = await _userService.getTaskLists();
      _setTaskLists(taskLists);
    } catch (error) {
      _onError(error);
    } finally {}
  }

  Future<void> _getTaskWidgets() async {
    debugPrint('get task widget list');
    try {
      List<TaskWidget> taskWidgets = await _userService.getTaskWidgets();
      _setTaskWidgets(taskWidgets);
    } catch (error) {
      _onError(error);
    } finally {}
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

  void _setTaskLists(List<TaskList> taskLists) {
    setState(() {
      _taskLists = taskLists;
    });
  }

  void _setTaskWidgets(List<TaskWidget> taskWidgets) {
    setState(() {
      _taskWidgets = taskWidgets;
    });
  }

  void _setRefreshInProgress(bool refreshInProgress) {
    setState(() {
      _refreshInProgress = refreshInProgress;
    });
  }
}

class OFTaskListPageController extends PoppablePageController {
  OFTaskListPageState _state;

  void attach({@required BuildContext context, OFTaskListPageState state}) {
    super.attach(context: context);
    _state = state;
  }

  Future<void> refresh() {
    return _state.refresh();
  }
}
