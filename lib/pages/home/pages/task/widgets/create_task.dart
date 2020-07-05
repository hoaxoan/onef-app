import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/models/task.dart';
import 'package:onef/pages/home/pages/task/widgets/create_task_text.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/services/validation.dart';
import 'package:onef/widgets/contextual_search_boxes/contextual_search_box_state.dart';
import 'package:onef/widgets/theming/primary_color_container.dart';

class OFSaveTaskModal extends StatefulWidget {
  final Task task;

  const OFSaveTaskModal({Key key, this.task}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OFSaveTaskModalState();
  }
}

class OFSaveTaskModalState extends OFContextualSearchBoxState<OFSaveTaskModal> {
  ValidationService _validationService;
  UserService _userService;
  ToastService _toastService;
  LocalizationService _localizationService;

  TextEditingController _textController;
  FocusNode _focusNode;
  int _charactersCount;

  bool _isPostTextAllowedLength;
  bool _isPostTextContainingValidHashtags;

  bool _hasFocus;

  List<Widget> _postItemsWidgets;

  bool _needsBootstrap;
  bool _isEditingTask;

  bool _saveInProgress;
  CancelableOperation _saveOperation;

  @override
  void initState() {
    super.initState();
    _isEditingTask = widget.task != null;

    _focusNode = FocusNode();
    _hasFocus = false;
    _isPostTextAllowedLength = false;
    _isPostTextContainingValidHashtags = false;
    _needsBootstrap = true;

    _focusNode.addListener(_onFocusNodeChanged);
  }

  @override
  void bootstrap() {
    super.bootstrap();

    if (_isEditingTask) {
      _saveInProgress = false;
      _textController = TextEditingController(text: widget.task?.name ?? '');
      _postItemsWidgets = [
        OFCreateTaskText(controller: _textController, focusNode: _focusNode)
      ];
    } else {
      _textController = TextEditingController(text: widget.task?.name ?? '');
      _postItemsWidgets = [
        OFCreateTaskText(controller: _textController, focusNode: _focusNode)
      ];
    }

    setAutocompleteTextController(_textController);

    _textController.addListener(_onNoteTextChanged);
    _charactersCount = _textController.text.length;
    _isPostTextAllowedLength =
        _validationService.isPostTextAllowedLength(_textController.text);
    _isPostTextContainingValidHashtags = _validationService
        .isPostTextContainingValidHashtags(_textController.text);
  }

  @override
  void dispose() {
    super.dispose();
    _textController.removeListener(_onNoteTextChanged);
    _focusNode.removeListener(_onFocusNodeChanged);
    _saveOperation?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OneFProvider.of(context);
      _validationService = provider.validationService;
      _localizationService = provider.localizationService;
      _toastService = provider.toastService;
      _userService = provider.userService;
      bootstrap();
      _needsBootstrap = false;
    }

    return CupertinoPageScaffold(
        backgroundColor: Colors.transparent,
        //navigationBar: _buildNavigationBar(_localizationService),
        child: OFPrimaryColorContainer(
            child: Column(
          children: <Widget>[
            Expanded(
                flex: isAutocompleting ? 3 : 1,
                child: Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 20.0),
                  child: _buildNewTaskContent(),
                )),
            isAutocompleting
                ? Expanded(
                    flex: 7,
                    child: buildSearchBox(),
                  )
                : const SizedBox(),
            isAutocompleting
                ? const SizedBox()
                : Container(
                    height: _hasFocus == true ? 51 : 67,
                    padding: EdgeInsets.only(
                        top: 8.0, bottom: _hasFocus == true ? 8 : 24),
                    color: Color.fromARGB(5, 0, 0, 0),
                    child: _buildTaskActions(),
                  ),
          ],
        )));
  }

  Widget _buildNewTaskContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Column(
          children: <Widget>[],
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _postItemsWidgets,
                )),
          ),
        )
      ],
    );
  }

  Widget _buildTaskActions() {
    List<Widget> postActions = [];

    if (postActions.isEmpty) return const SizedBox();

    return ListView.separated(
      physics: const ClampingScrollPhysics(),
      itemCount: postActions.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, index) {
        var postAction = postActions[index];

        return index == 0
            ? Row(
                children: <Widget>[
                  const SizedBox(
                    width: 10,
                  ),
                  postAction
                ],
              )
            : postAction;
      },
      separatorBuilder: (BuildContext context, index) {
        return const SizedBox(
          width: 10,
        );
      },
    );
  }

  void _onNoteTextChanged() {
    String text = _textController.text;
    setState(() {
      _charactersCount = text.length;
      _isPostTextAllowedLength =
          _validationService.isPostTextAllowedLength(text);
      _isPostTextContainingValidHashtags =
          _validationService.isPostTextContainingValidHashtags(text);
    });
  }

  void _onFocusNodeChanged() {
    _hasFocus = _focusNode.hasFocus;
  }
}
