import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:onef/models/task.dart';
import 'package:onef/models/task_list.dart';
import 'package:onef/models/task_widget.dart';
import 'package:onef/models/user.dart';
import 'package:onef/pages/home/lib/poppable_page_controller.dart';
import 'package:onef/pages/home/pages/task/task_detail_page.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/bottom_sheet.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/modal_service.dart';
import 'package:onef/services/theme.dart';
import 'package:onef/services/theme_value_parser.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/action_button.dart';
import 'package:onef/widgets/task/completed_task.dart';
import 'package:onef/widgets/task/pending_task.dart';

class OFTaskPage extends StatefulWidget {
  final OFTaskPageController controller;

  OFTaskPage({
    @required this.controller,
  });
  @override
  State<OFTaskPage> createState() {
    return OFTaskPageState();
  }
}

class OFTaskPageState extends State<OFTaskPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  UserService _userService;
  ModalService _modalService;
  BottomSheetService _bottomSheetService;
  ToastService _toastService;
  LocalizationService _localizationService;
  ThemeService _themeService;
  ThemeValueParserService _themeValueParserService;

  TaskList _taskList;
  bool _refreshInProgress;
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;

  StreamSubscription _loggedInUserChangeSubscription;
  bool _needsBootstrap;
  bool _loggedInUserBootstrapped;

  @override
  void initState() {
    super.initState();
    widget.controller.attach(context: context, state: this);
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

      _refreshTaskList();
      _needsBootstrap = false;
    }

    return RefreshIndicator(
        onRefresh: _refreshTaskList,
        key: _refreshIndicatorKey,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          resizeToAvoidBottomPadding: true,
          floatingActionButton: _fab,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          appBar: AppBar(
            backgroundColor: _taskList != null && _taskList.color != null
                ? Color(_taskList.color.start)
                : Color.fromRGBO(230, 113, 153, 1),
            elevation: 0.0,
            leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context, true);
                }),
            /* title: OFText(
              _taskList.name,
              style: TextStyle(
                color: Colors.white,
              ),
            ),*/
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                //onPressed: () => _modalBottomSheetMore(context),
              )
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _taskList != null && _taskList.color != null
                      ? Color(_taskList.color.start)
                      : Color.fromRGBO(230, 113, 153, 1),
                  _taskList != null && _taskList.color != null
                      ? Color(_taskList.color.end)
                      : Color.fromRGBO(230, 113, 153, 1)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: CustomScrollView(
                key: Key(new Random(new DateTime.now().millisecondsSinceEpoch)
                    .toString()),
                slivers: <Widget>[
                  _taskList != null
                      ? OFPendingTask(
                          taskList: _taskList,
                          tasks: _taskList?.tasks,
                          onView: _onViewPendingTask,
                        )
                      : SliverFillRemaining(),
                  _taskList != null
                      ? OFCompletedTask(
                          taskList: _taskList,
                          tasks: _taskList?.tasks,
                          onView: _onViewCompletedTask,
                        )
                      : SliverFillRemaining(),
                ],
              ),
            ),
          ),
        ));
  }

  void _onViewPendingTask(Task task) async {
    var route = MaterialPageRoute(builder: (BuildContext context) {
      return OFTaskDetailPage(taskList: _taskList, task: task);
    });
    await Navigator.of(context, rootNavigator: true).push(route);
  }

  void _onViewCompletedTask(Task task) async {
    var route = MaterialPageRoute(builder: (BuildContext context) {
      return OFTaskDetailPage(taskList: _taskList, task: task);
    });
    await Navigator.of(context, rootNavigator: true).push(route);
  }

  Future<void> _refreshTaskList() async {
    debugPrint('Refreshing task list');
    _setRefreshInProgress(true);
    try {
      _getTaskList();
    } catch (error) {
      _onError(error);
    } finally {
      _setRefreshInProgress(false);
    }
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

  Future<void> _getTaskList() async {
    debugPrint('get task list');
    try {
      TaskList taskList =
          await _userService.getTaskListByState(TaskWidgetState.Today);
      _setTaskList(taskList);
    } catch (error) {
      _onError(error);
    } finally {}
  }

  void _setTaskList(TaskList taskList) {
    setState(() {
      _taskList = taskList;
    });
  }

  void _setRefreshInProgress(bool refreshInProgress) {
    setState(() {
      _refreshInProgress = refreshInProgress;
    });
  }

  Future refresh() {
    //return _notesStreamController.refreshNotes();
  }

  Widget get _fab {
    return AnimatedBuilder(
      animation: ModalRoute.of(context).animation,
      child: OFActionButton(
        onPressed: () async {
          /* showRoundedModalBottomSheet<Task>(
              context: context,
              builder: (BuildContext context) {
                return AddTaskWidget();
              }).then((newTask) async {
            await model.onNewTaskSave(newTask);
          });*/

          await _onCreateTask();
        },
      ),
      builder: (BuildContext context, Widget fab) {
        final Animation<double> animation = ModalRoute.of(context).animation;
        return SizedBox(
          width: 54 * animation.value,
          height: 54 * animation.value,
          child: fab,
        );
      },
    );
  }

  Future<void> _onCreateTask() async {
    await _bottomSheetService.showAddTask(context: context);
  }

/*  Future<bool> _onCreateTask() async {
    OFNewTaskData createTaskData =
        await _modalService.openCreateTask(context: context);
    if (createTaskData != null) {
      return true;
    }

    return false;
  }*/
}

class OFTaskPageController extends PoppablePageController {
  OFTaskPageState _state;

  void attach({@required BuildContext context, OFTaskPageState state}) {
    super.attach(context: context);
    _state = state;
  }

  Future<void> refresh() {
    return _state.refresh();
  }
}
