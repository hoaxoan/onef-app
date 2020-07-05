import 'package:flutter/material.dart';
import 'package:onef/models/theme.dart';
import 'package:onef/provider.dart';
import 'package:onef/widgets/fields/text_field.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/theming/text.dart';

class OFSearchBar extends StatefulWidget {
  final OBSearchBarOnSearch onSearch;
  final VoidCallback onCancel;
  final String hintText;

  OFSearchBar({Key key, @required this.onSearch, this.hintText, this.onCancel})
      : super(key: key);

  @override
  OFSearchBarState createState() {
    return OFSearchBarState();
  }
}

class OFSearchBarState extends State<OFSearchBar> {
  TextEditingController _textController;
  FocusNode _textFocusNode;

  @override
  void initState() {
    super.initState();
    _textFocusNode = FocusNode();
    _textController = TextEditingController();
    _textController.addListener(() {
      widget.onSearch(_textController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool hasText = _textController.text.length > 0;
    EdgeInsetsGeometry inputContentPadding = EdgeInsets.only(
        top: 8.0, bottom: 8.0, left: 20, right: hasText ? 40 : 20);

    var provider = OneFProvider.of(context);
    var localizationService = provider.localizationService;
    var themeService = provider.themeService;
    var themeValueParserService = provider.themeValueParserService;

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OFTheme> snapshot) {
          var theme = snapshot.data;
          Color primaryColor =
              themeValueParserService.parseColor(theme.primaryColor);
          final bool isDarkPrimaryColor =
              primaryColor.computeLuminance() < 0.179;

          return Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  width: 15.0,
                ),
                const OFIcon(OFIcons.search),
                const SizedBox(
                  width: 15.0,
                ),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: isDarkPrimaryColor
                          ? Color.fromARGB(20, 255, 255, 255)
                          : Color.fromARGB(10, 0, 0, 0),
                    ),
                    child: Stack(
                      children: <Widget>[
                        OFTextField(
                          textInputAction: TextInputAction.go,
                          focusNode: _textFocusNode,
                          controller: _textController,
                          keyboardType: TextInputType.text,
                          style: TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                              hintText: widget.hintText,
                              contentPadding: inputContentPadding,
                              border: InputBorder.none),
                          autocorrect: true,
                        ),
                        hasText
                            ? Positioned(
                                right: 0,
                                child: _buildClearButton(),
                              )
                            : const SizedBox()
                      ],
                    ),
                  ),
                ),
                hasText
                    ? FlatButton(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        child: OFText(localizationService.user_search__cancel),
                        onPressed: _cancelSearch,
                      )
                    : const SizedBox(
                        width: 15.0,
                      )
              ],
            ),
          );
        });
  }

  Widget _buildClearButton() {
    return GestureDetector(
      child: SizedBox(
        height: 35.0,
        width: 35.0,
        child: const OFIcon(
          OFIcons.close,
          customSize: 15.0,
        ),
      ),
      onTap: _clearText,
    );
  }

  void _clearText() {
    _textController.clear();
  }

  void _cancelSearch() {
    // Unfocus text
    FocusScope.of(context).requestFocus(new FocusNode());
    _textController.clear();
    if (widget.onCancel != null) widget.onCancel();
  }
}

typedef void OBSearchBarOnSearch(String searchString);
