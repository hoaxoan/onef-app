import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:onef/models/task.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/linear_progress_indicator.dart';
import 'package:onef/widgets/theming/highlighted_box.dart';
import 'package:onef/widgets/theming/text.dart';

import 'icon.dart';

class OFNewTaskDataUploader extends StatefulWidget {
  final OFNewTaskData data;
  final Function(Task, OFNewTaskData) onTaskPublished;
  final ValueChanged<OFNewTaskData> onCancelled;

  const OFNewTaskDataUploader(
      {Key key,
      @required this.data,
      @required this.onTaskPublished,
      @required this.onCancelled})
      : super(key: key);

  @override
  OBNewPostDataUploaderState createState() {
    return OBNewPostDataUploaderState();
  }
}

class OBNewPostDataUploaderState extends State<OFNewTaskDataUploader>
    with AutomaticKeepAliveClientMixin {
  UserService _userService;
  LocalizationService _localizationService;

  bool _needsBootstrap;
  OFTaskUploaderStatus _status;

  String _statusMessage = '';

  Timer _checkTaskStatusTimer;

  CancelableOperation _getTaskStatusOperation;
  CancelableOperation _uploadTaskOperation;
  OFNewTaskData _data;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _data = widget.data;
    _status = OFTaskUploaderStatus.idle;
  }

  @override
  void dispose() {
    super.dispose();
    _ensureTaskStatusTimerIsCancelled();
    _getTaskStatusOperation?.cancel();
    _uploadTaskOperation?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OneFProvider.of(context);
      _userService = provider.userService;
      _localizationService = provider.localizationService;
      _bootstrap();
      _needsBootstrap = false;
    }

    List<Widget> rowItems = [];

    rowItems.addAll([_buildStatusText(), _buildActionButtons()]);

    return OFHighlightedBox(
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Row(children: rowItems),
                    ],
                  ),
                )
              ],
            ),
          ),
          Positioned(
            bottom: -3,
            left: 0,
            right: 0,
            child: _status == OFTaskUploaderStatus.creatingPost ||
                    _status == OFTaskUploaderStatus.compressingPostMedia ||
                    _status == OFTaskUploaderStatus.addingPostMedia ||
                    _status == OFTaskUploaderStatus.processing
                ? _buildProgressBar()
                : const SizedBox(),
          )
        ],
      ),
    );
  }

  void _bootstrap() {
    _startUpload();
  }

  void _startUpload() {
    _uploadTaskOperation = CancelableOperation.fromFuture(_uploadTask());
  }

  Future _uploadTask() async {
    try {
      if (_data.createdDraftTask == null) {
        _setStatus(OFTaskUploaderStatus.creatingPost);
        _setStatusMessage(_localizationService.post_uploader__creating_post);
        _data.createdDraftTask = await _createTask();
      }

      if (!_data.taskPublishRequested) {
        _setStatusMessage(_localizationService.post_uploader__publishing);
        _setStatus(OFTaskUploaderStatus.publishing);
        await _publishPost();
        _data.taskPublishRequested = true;
      }

      _setStatusMessage(_localizationService.post_uploader__processing);
      _setStatus(OFTaskUploaderStatus.processing);
      _ensureTaskStatusTimerIsCancelled();

      if (_data.createdDraftTaskStatus == null ||
          _data.createdDraftTaskStatus != OFTaskStatus.published) {
        _checkTaskStatusTimer =
            Timer.periodic(new Duration(seconds: 1), (timer) async {
          if (_getTaskStatusOperation != null) return;
          _getTaskStatusOperation = CancelableOperation.fromFuture(
              _userService.getTaskStatus(task: _data.createdDraftTask));
          OFTaskStatus status = await _getTaskStatusOperation.value;
          debugLog(
              'Polling for post published status, got status: ${status.toString()}');
          _data.createdDraftTaskStatus = status;
          if (_data.createdDraftTaskStatus == OFTaskStatus.published) {
            debugLog('Received post status is published');
            _checkTaskStatusTimer.cancel();
            _getPublishedTask();
          }
          _getTaskStatusOperation = null;
        });
      } else {
        _getPublishedTask();
      }
    } catch (error) {
      if (error is HttpieConnectionRefusedError) {
        _setStatusMessage(error.toHumanReadableMessage());
      } else if (error is HttpieRequestError) {
        String errorMessage = await error.toHumanReadableMessage();
        _setStatusMessage(errorMessage);
      } else {
        _setStatusMessage(
            _localizationService.post_uploader__generic_upload_failed);
        // only throw error if its not one of the above handled errors
        throw error;
      }
      _setStatus(OFTaskUploaderStatus.failed);
    }
  }

  Future _createTask() async {
    Task draftPost;

    debugLog('Post created successfully');

    return draftPost;
  }

  Future _getPublishedTask() async {
    debugLog('Retrieving the published task');

    Task publishedTask =
        await _userService.getTaskWithUuid(_data.createdDraftTask.uuid);
    widget.onTaskPublished(publishedTask, widget.data);
  }

  Widget _buildProgressBar() {
    return OFLinearProgressIndicator();
  }

  Widget _buildStatusText() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            OFText(
              _statusMessage,
              textAlign: TextAlign.left,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    List<Widget> activeActions = [];

    switch (_status) {
      case OFTaskUploaderStatus.creatingPost:
      case OFTaskUploaderStatus.addingPostMedia:
        activeActions.add(_buildCancelButton());
        break;
      case OFTaskUploaderStatus.failed:
        activeActions.add(_buildCancelButton());
        activeActions.add(_buildRetryButton());
        break;
      default:
    }

    return Row(
      children: activeActions,
    );
  }

  Widget _buildCancelButton() {
    return GestureDetector(
      onTap: _onWantsToCancel,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: OFIcon(OFIcons.cancel),
      ),
    );
  }

  Widget _buildRetryButton() {
    return GestureDetector(
      onTap: _onWantsToRetry,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: OFIcon(OFIcons.retry),
      ),
    );
  }

  void _onWantsToRetry() async {
    if (_status == OFTaskUploaderStatus.creatingPost ||
        _status == OFTaskUploaderStatus.addingPostMedia) return;

    debugLog('Retrying');
    _startUpload();
  }

  void _onWantsToCancel() async {
    if (_status == OFTaskUploaderStatus.cancelling) return;
    _setStatus(OFTaskUploaderStatus.cancelling);

    debugLog('Cancelling');

    // Delete post
    if (_data.createdDraftTask != null) {
      debugLog('Deleting task');
      try {
        await _userService.deleteTask(_data.createdDraftTask);
        debugLog('Successfully deleted task');
      } catch (error) {
        // If it doesnt work, will get cleaned up by a scheduled job
        debugLog('Failed to delete post wit error: ${error.toString()}');
      }
    }

    _setStatus(OFTaskUploaderStatus.cancelled);
    widget.onCancelled(widget.data);
  }

  Future _publishPost() async {
    debugLog('Publishing task');
    return _userService.publishTask(task: _data.createdDraftTask);
  }

  void _setStatus(OFTaskUploaderStatus status) {
    if (mounted) {
      setState(() {
        _status = status;
      });
    }
  }

  void _setStatusMessage(String statusMessage) {
    if (mounted) {
      setState(() {
        _statusMessage = statusMessage;
      });
    }
  }

  void _ensureTaskStatusTimerIsCancelled() {
    if (_checkTaskStatusTimer != null && _checkTaskStatusTimer.isActive)
      _checkTaskStatusTimer.cancel();
  }

  void debugLog(String log) {
    debugPrint('OBNewPostDataUploader:$log');
  }

  @override
  bool get wantKeepAlive => true;
}

class OFNewTaskData {
  String text;

  // State persistence variables
  Task createdDraftTask;
  OFTaskStatus createdDraftTaskStatus;
  bool taskPublishRequested = false;

  String _cachedKey;

  OFNewTaskData({this.text}) {}

  String getUniqueKey() {
    if (_cachedKey != null) return _cachedKey;

    String key = '';
    if (text != null) key += text;

    var bytes = utf8.encode(key);
    var digest = sha256.convert(bytes);

    _cachedKey = digest.toString();

    return _cachedKey;
  }
}

enum OFTaskUploaderStatus {
  idle,
  creatingPost,
  compressingPostMedia,
  addingPostMedia,
  publishing,
  processing,
  success,
  failed,
  cancelling,
  cancelled,
}
