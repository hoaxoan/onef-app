import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:onef/models/hashtag.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/theming/actionable_smart_text.dart';
import 'package:onef/widgets/theming/secondary_text.dart';
import 'package:onef/widgets/theming/smart_text.dart';
import 'package:onef/widgets/theming/text.dart';

class OFCollapsibleSmartText extends StatefulWidget {
  final String text;
  final int maxlength;
  final OFTextSize size;
  final TextOverflow overflow;
  final TextOverflow lengthOverflow;
  final SmartTextElement trailingSmartTextElement;
  final Function getChild;
  final Map<String, Hashtag> hashtagsMap;

  const OFCollapsibleSmartText(
      {Key key,
      this.text,
      this.maxlength,
      this.size = OFTextSize.medium,
      this.overflow = TextOverflow.clip,
      this.lengthOverflow = TextOverflow.ellipsis,
      this.getChild,
      this.trailingSmartTextElement,
      this.hashtagsMap})
      : super(key: key);

  @override
  OFCollapsibleSmartTextState createState() {
    return OFCollapsibleSmartTextState();
  }
}

class OFCollapsibleSmartTextState extends State<OFCollapsibleSmartText> {
  ExpandableController _expandableController;

  @override
  void initState() {
    super.initState();
    _expandableController = ExpandableController();
  }

  @override
  Widget build(BuildContext context) {
    bool shouldBeCollapsed = widget.text.length > widget.maxlength;
    LocalizationService _localizationService =
        OneFProvider.of(context).localizationService;

    return shouldBeCollapsed
        ? _buildExpandableActionableSmartText(_localizationService)
        : _buildActionableSmartText();
  }

  Widget _buildExpandableActionableSmartText(
      LocalizationService _localizationService) {
    return ExpandableNotifier(
      controller: _expandableController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expandable(
            collapsed: _buildActionableSmartText(maxLength: widget.maxlength),
            expanded: _buildActionableSmartText(),
          ),
          Builder(builder: (BuildContext context) {
            var exp = ExpandableController.of(context);

            if (exp.expanded) return const SizedBox();

            return GestureDetector(
                onTap: _toggleExpandable,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      widget.getChild(),
                      Row(
                        children: <Widget>[
                          OFSecondaryText(
                            _localizationService.post__actions_show_more_text,
                            size: widget.size,
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          OFIcon(
                            OFIcons.arrowDown,
                            themeColor: OFIconThemeColor.secondaryText,
                          )
                        ],
                      ),
                    ],
                  ),
                ));
          })
        ],
      ),
    );
  }

  void _toggleExpandable() {
    _expandableController.toggle();
  }

  Widget _buildActionableSmartText({int maxLength}) {
    Widget translateButton;

    if (maxLength != null) {
      translateButton = SizedBox();
    } else {
      translateButton = Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: widget.getChild(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        OFActionableSmartText(
          text: widget.text,
          maxlength: maxLength,
          size: widget.size,
          lengthOverflow: widget.lengthOverflow,
          trailingSmartTextElement: widget.trailingSmartTextElement,
          hashtagsMap: widget.hashtagsMap,
        ),
        translateButton
      ],
    );
  }
}
