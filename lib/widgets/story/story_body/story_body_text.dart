import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onef/models/story.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/httpie.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/services/toast.dart';
import 'package:onef/services/user.dart';
import 'package:onef/widgets/theming/collapsible_smart_text.dart';
import 'package:onef/widgets/theming/secondary_text.dart';
import 'package:onef/widgets/theming/smart_text.dart';
import 'package:onef/widgets/theming/text.dart';

class OFStoryBodyText extends StatefulWidget {
  final Story story;
  final OnTextExpandedChange onTextExpandedChange;

  OFStoryBodyText(this.story, {this.onTextExpandedChange}) : super();

  @override
  OFStoryBodyTextState createState() {
    return OFStoryBodyTextState();
  }
}

class OFStoryBodyTextState extends State<OFStoryBodyText> {
  static const int MAX_LENGTH_LIMIT = 1300;

  ToastService _toastService;
  UserService _userService;
  LocalizationService _localizationService;
  String _translatedText;
  bool _translationInProgress;
  bool _needsBootstrap;

  @override
  void initState() {
    super.initState();
    _translationInProgress = false;
    _translatedText = null;
    _needsBootstrap = true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = OneFProvider.of(context);
      _toastService = provider.toastService;
      _userService = provider.userService;
      _localizationService = provider.localizationService;
      _needsBootstrap = false;
    }

    return GestureDetector(
      onLongPress: _copyText,
      child: _buildFullPostText(),
    );
  }

  Widget _buildFullPostText() {
    return StreamBuilder(
        stream: widget.story.updateSubject,
        initialData: widget.story,
        builder: (BuildContext context, AsyncSnapshot<Story> snapshot) {
          return _buildStoryText();
        });
  }

  Widget _buildStoryText() {
    return Padding(
        padding: EdgeInsets.only(top: 10, left: 20, right: 20),
        child: _buildActionableStoryText());
  }

  Future<String> _translateStoryText() async {
    String translatedText;
    try {
      _setTranslationInProgress(true);
      translatedText = widget.story.title;
    } catch (error) {
      _onError(error);
    } finally {
      _setTranslationInProgress(false);
    }
    return translatedText;
  }

  Widget _buildActionableStoryText() {
    return OFCollapsibleSmartText(
      text: _translatedText != null ? _translatedText : widget.story.title,
      trailingSmartTextElement: SecondaryTextElement(' (edited)'),
      maxlength: MAX_LENGTH_LIMIT,
      getChild: _buildTranslationButton,
    );
  /*  if (widget.story.isEdited != null && widget.story.isEdited) {
      return OFCollapsibleSmartText(
        text: _translatedText != null ? _translatedText : widget.story.title,
        trailingSmartTextElement: SecondaryTextElement(' (edited)'),
        maxlength: MAX_LENGTH_LIMIT,
        getChild: _buildTranslationButton,
      );
    } else {
      return OFCollapsibleSmartText(
        text: _translatedText != null ? _translatedText : widget.story.title,
        maxlength: MAX_LENGTH_LIMIT,
        getChild: _buildTranslationButton,
      );
    }*/
  }

  Widget _buildTranslationButton() {
    if (_translationInProgress) {
      return Padding(
          padding: EdgeInsets.all(10.0),
          child: Container(
            width: 10.0,
            height: 10.0,
            child: CircularProgressIndicator(strokeWidth: 2.0),
          ));
    }

    return GestureDetector(
      onTap: () async {
        if (_translatedText == null) {
          String translatedText = await _translateStoryText();
          _setTranslatedText(translatedText);
        } else {
          _setTranslatedText(null);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _translatedText != null
            ? OFSecondaryText(
                _localizationService.trans('user__translate_show_original'),
                size: OFTextSize.large)
            : OFSecondaryText(
                _localizationService.trans('user__translate_see_translation'),
                size: OFTextSize.large),
      ),
    );
  }

  void _copyText() {
    Clipboard.setData(ClipboardData(text: widget.story.title));
    _toastService.toast(
        message: _localizationService.post__text_copied,
        context: context,
        type: ToastType.info);
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
    } else {
      _toastService.error(
          message: _localizationService.error__unknown_error, context: context);
      throw error;
    }
  }

  void _setTranslationInProgress(bool translationInProgress) {
    setState(() {
      _translationInProgress = translationInProgress;
    });
  }

  void _setTranslatedText(String translatedText) {
    setState(() {
      _translatedText = translatedText;
    });
  }
}

typedef void OnTextExpandedChange(
    {@required Story story, @required bool isExpanded});
