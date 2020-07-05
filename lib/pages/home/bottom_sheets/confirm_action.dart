import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/pages/home/bottom_sheets/rounded_bottom_sheet.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/widgets/buttons/button.dart';
import 'package:onef/widgets/theming/text.dart';

class OFConfirmActionBottomSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final String confirmText;
  final String cancelText;
  final ActionCompleter actionCompleter;

  const OFConfirmActionBottomSheet(
      {this.title,
      @required this.actionCompleter,
      this.confirmText,
      this.cancelText,
      this.subtitle});

  @override
  State<StatefulWidget> createState() {
    return OFConfirmActionBottomSheetState();
  }
}

class OFConfirmActionBottomSheetState
    extends State<OFConfirmActionBottomSheet> {
  ToastService _toastService;
  LocalizationService _localizationService;
  bool _needsBootstrap;

  bool _isConfirmActionInProgress;
  CancelableOperation _confirmActionOperation;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _isConfirmActionInProgress = false;
  }

  @override
  void dispose() {
    super.dispose();
    _confirmActionOperation?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var oneFProvider = OneFProvider.of(context);
      _toastService = oneFProvider.toastService;
      _localizationService = oneFProvider.localizationService;
      _needsBootstrap = false;
    }

    final confirmationText = widget.title ??
        _localizationService.bottom_sheets__confirm_action_are_you_sure;
    final confirmText = widget.confirmText ??
        _localizationService.bottom_sheets__confirm_action_yes;
    final cancelText = widget.confirmText ??
        _localizationService.bottom_sheets__confirm_action_no;

    List<Widget> columnItems = [
      OFText(
        confirmationText,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        textAlign: TextAlign.left,
      ),
    ];

    if (widget.subtitle != null) {
      columnItems.addAll([
        const SizedBox(
          height: 10,
        ),
        OFText(
          widget.subtitle,
          size: OFTextSize.large,
          textAlign: TextAlign.left,
        ),
      ]);
    }

    columnItems.addAll([
      const SizedBox(
        height: 20,
      ),
      Row(
        children: <Widget>[
          Expanded(
            child: OFButton(
              size: OFButtonSize.large,
              child: Text(cancelText),
              type: OFButtonType.danger,
              onPressed: _onPressedCancel,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: OFButton(
              size: OFButtonSize.large,
              child: Text(confirmText),
              type: OFButtonType.success,
              isLoading: _isConfirmActionInProgress,
              onPressed: _onPressedConfirm,
            ),
          )
        ],
      )
    ]);

    return OFRoundedBottomSheet(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: columnItems),
    ));
  }

  Future<void> _onPressedConfirm() async {
    _setConfirmActionInProgress(true);
    try {
      await widget.actionCompleter(context);
      Navigator.pop(context);
    } catch (error) {
      _onError(error);
      rethrow;
    } finally {
      _setConfirmActionInProgress(false);
    }
  }

  void _onPressedCancel() {
    Navigator.pop(context);
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

  void _setConfirmActionInProgress(bool confirmActionInProgress) {
    setState(() {
      _isConfirmActionInProgress = confirmActionInProgress;
    });
  }
}

typedef Future ActionCompleter(BuildContext context);
