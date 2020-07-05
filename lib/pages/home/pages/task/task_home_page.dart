import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:onef/models/task.dart';
import 'package:onef/models/task_home.dart';
import 'package:onef/models/task_home_list.dart';
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
import 'package:onef/widgets/task/home_task_list.dart';

class OFTaskHomePage extends StatefulWidget {
  final OFTaskHomePageController controller;

  OFTaskHomePage({
    @required this.controller,
  });
  @override
  State<OFTaskHomePage> createState() {
    return OFTaskHomePageState();
  }
}

class OFTaskHomePageState extends State<OFTaskHomePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  UserService _userService;
  ModalService _modalService;
  BottomSheetService _bottomSheetService;
  ToastService _toastService;
  LocalizationService _localizationService;
  ThemeService _themeService;
  ThemeValueParserService _themeValueParserService;

  TaskHomeList _taskHomeList;
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

      _refreshTaskHomeList();
      _needsBootstrap = false;
    }

    return RefreshIndicator(
        onRefresh: _refreshTaskHomeList,
        key: _refreshIndicatorKey,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          resizeToAvoidBottomPadding: true,
          floatingActionButton: _fab,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          appBar: AppBar(
            backgroundColor: Color.fromRGBO(230, 113, 153, 1),
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
                  Color.fromRGBO(230, 113, 153, 1),
                  Color.fromRGBO(230, 113, 153, 1)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: CustomScrollView(
                key: Key(new Random(new DateTime.now().millisecondsSinceEpoch)
                    .toString()),
                slivers:
                    _taskHomeList != null && _taskHomeList.taskHomes != null
                        ? _buildTaskHomeList(context)
                        : [],
              ),
            ),
          ),
        ));
  }

  List<Widget> _buildTaskHomeList(BuildContext context) {
    return _taskHomeList.taskHomes
        .map<Widget>((TaskHome taskHome) => OFHomeTaskList(
              taskHome: taskHome,
              onView: _onViewTask,
            ))
        .toList();
  }

  void _onViewTask(Task task) async {
    var route = MaterialPageRoute(builder: (BuildContext context) {
      return OFTaskDetailPage(task: task);
    });
    await Navigator.of(context, rootNavigator: true).push(route);
  }

  Future<void> _refreshTaskHomeList() async {
    debugPrint('Refreshing task home list');
    _setRefreshInProgress(true);
    try {
      _getTaskHomeList();
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

  Future<void> _getTaskHomeList() async {
    debugPrint('get task home list');
    try {
      TaskHomeList taskHomeList = await _userService.getTaskHomeList();
      _setTaskHomeList(taskHomeList);
    } catch (error) {
      _onError(error);
    } finally {}
  }

  void _setTaskHomeList(TaskHomeList taskHomeList) {
    setState(() {
      _taskHomeList = taskHomeList;
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

class OFTaskHomePageController extends PoppablePageController {
  OFTaskHomePageState _state;

  void attach({@required BuildContext context, OFTaskHomePageState state}) {
    super.attach(context: context);
    _state = state;
  }

  Future<void> refresh() {
    return _state.refresh();
  }
}
