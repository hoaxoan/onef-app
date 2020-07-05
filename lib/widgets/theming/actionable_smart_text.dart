import 'dart:async';

import 'package:flutter/material.dart';
import 'package:onef/models/hashtag.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/theming/smart_text.dart';
import 'package:onef/widgets/theming/text.dart';

class OFActionableSmartText extends StatefulWidget {
  final String text;
  final int maxlength;
  final OFTextSize size;
  final TextOverflow overflow;
  final TextOverflow lengthOverflow;
  final SmartTextElement trailingSmartTextElement;
  final Map<String, Hashtag> hashtagsMap;

  const OFActionableSmartText(
      {Key key,
      this.text,
      this.maxlength,
      this.size = OFTextSize.medium,
      this.overflow = TextOverflow.clip,
      this.lengthOverflow = TextOverflow.ellipsis,
      this.trailingSmartTextElement,
      this.hashtagsMap})
      : super(key: key);

  @override
  OFActionableTextState createState() {
    return OFActionableTextState();
  }
}

class OFActionableTextState extends State<OFActionableSmartText> {
  UserService _userService;
  ToastService _toastService;

  bool _needsBootstrap;
  StreamSubscription _requestSubscription;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
  }

  void dispose() {
    super.dispose();
    _clearRequestSubscription();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var oneFrovider = OneFProvider.of(context);
      _userService = oneFrovider.userService;
      _toastService = oneFrovider.toastService;
      _needsBootstrap = false;
    }

    return OBSmartText(
      text: widget.text,
      maxlength: widget.maxlength,
      overflow: widget.overflow,
      lengthOverflow: widget.lengthOverflow,
      trailingSmartTextElement: widget.trailingSmartTextElement,
      hashtagsMap: widget.hashtagsMap,
      size: widget.size,
    );
  }

  void _onRequestDone() {
    _clearRequestSubscription();
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage, context: context);
    } else {
      _toastService.error(message: 'Unknown error', context: context);
      throw error;
    }
  }

  void _clearRequestSubscription() {
    if (_requestSubscription != null) {
      _requestSubscription.cancel();
      _setRequestSubscription(null);
    }
  }

  void _setRequestSubscription(StreamSubscription requestSubscription) {
    _requestSubscription = requestSubscription;
  }
}
