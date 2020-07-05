import 'package:flutter/material.dart';
import 'package:onef/models/theme.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/theme_value_parser.dart';

class OFButton extends StatelessWidget {
  final Widget child;
  final Widget icon;
  final VoidCallback onPressed;
  final VoidCallback onLongPressed;
  final bool isDisabled;
  final bool isLoading;
  final OFButtonSize size;
  final double minWidth;
  final EdgeInsets padding;
  final OFButtonType type;
  final ShapeBorder shape;
  final double minHeight;
  final List<BoxShadow> boxShadow;
  final TextStyle textStyle;
  final Color color;
  final Color textColor;

  const OFButton(
      {@required this.child,
      @required this.onPressed,
      this.minHeight,
      this.minWidth,
      this.type = OFButtonType.primary,
      this.icon,
      this.size = OFButtonSize.medium,
      this.shape,
      this.boxShadow,
      this.isDisabled = false,
      this.isLoading = false,
      this.padding,
      this.textStyle,
      this.color,
      this.textColor,
      this.onLongPressed});

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    var themeService = provider.themeService;
    var themeValueParser = provider.themeValueParserService;

    return color != null
        ? _buildButton(color: color, textColor: textColor)
        : StreamBuilder(
            stream: themeService.themeChange,
            initialData: themeService.getActiveTheme(),
            builder: (BuildContext context, AsyncSnapshot<OFTheme> snapshot) {
              var theme = snapshot.data;
              Color buttonTextColor = _getButtonTextColorForType(type,
                  themeValueParser: themeValueParser, theme: theme);
              Gradient gradient = _getButtonGradientForType(type,
                  themeValueParser: themeValueParser, theme: theme);

              return _buildButton(
                  gradient: gradient, textColor: buttonTextColor);
            });
  }

  Widget _buildButton(
      {Gradient gradient, Color color, @required Color textColor}) {
    EdgeInsets buttonPadding = _getButtonPaddingForSize(size);
    double buttonMinWidth = minWidth ?? _getButtonMinWidthForSize(size);
    double buttonMinHeight = minHeight ?? 20;
    var finalOnPressed = isLoading || isDisabled ? () {} : onPressed;
    var finalOnLongPressed = isLoading || isDisabled ? () {} : onLongPressed;

    var buttonChild = isLoading ? _getLoadingIndicator(textColor) : child;

    if (isDisabled) buttonChild = Opacity(opacity: 0.5, child: buttonChild);

    if (icon != null && !isLoading) {
      buttonChild = Row(
        children: <Widget>[
          icon,
          const SizedBox(
            width: 5,
          ),
          buttonChild
        ],
      );
    }

    TextStyle defaultTextStyle =
        _getButtonTextStyleForSize(size: size, color: textColor);

    if (textStyle != null) {
      defaultTextStyle = defaultTextStyle.merge(textStyle);
    }

    return GestureDetector(
      child: Container(
          constraints: BoxConstraints(
              minWidth: buttonMinWidth, minHeight: buttonMinHeight),
          decoration: BoxDecoration(
              boxShadow: boxShadow ?? [],
              gradient: gradient,
              color: color,
              borderRadius: BorderRadius.circular(50.0)),
          child: Material(
            color: Colors.transparent,
            textStyle: defaultTextStyle,
            child: Padding(
              padding: buttonPadding,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[buttonChild],
              ),
            ),
          )),
      onTap: finalOnPressed,
      onLongPress: finalOnLongPressed,
    );
  }

  Widget _getLoadingIndicator(Color color) {
    return SizedBox(
      height: 18.0,
      width: 18.0,
      child: CircularProgressIndicator(
          strokeWidth: 2.0, valueColor: AlwaysStoppedAnimation<Color>(color)),
    );
  }

  Gradient _getButtonGradientForType(OFButtonType type,
      {@required ThemeValueParserService themeValueParser,
      @required OFTheme theme}) {
    Gradient buttonGradient;

    switch (type) {
      case OFButtonType.danger:
        buttonGradient = themeValueParser.parseGradient(theme.dangerColor);
        break;
      case OFButtonType.primary:
        buttonGradient =
            themeValueParser.parseGradient(theme.primaryAccentColor);
        break;
      case OFButtonType.success:
        buttonGradient = themeValueParser.parseGradient(theme.successColor);
        break;
      case OFButtonType.highlight:
        Color primaryColor = themeValueParser.parseColor(theme.primaryColor);
        final bool isDarkPrimaryColor = primaryColor.computeLuminance() < 0.179;
        Color gradientColor = isDarkPrimaryColor
            ? Color.fromARGB(30, 255, 255, 255)
            : Color.fromARGB(10, 0, 0, 0);

        buttonGradient = themeValueParser
            .makeGradientWithColors([gradientColor, gradientColor]);
        break;
      default:
    }

    return buttonGradient;
  }

  Color _getButtonTextColorForType(OFButtonType type,
      {@required ThemeValueParserService themeValueParser,
      @required OFTheme theme}) {
    Color buttonTextColor;

    switch (type) {
      case OFButtonType.danger:
        buttonTextColor = themeValueParser.parseColor(theme.dangerColorAccent);
        break;
      case OFButtonType.primary:
        buttonTextColor = Colors.white;
        break;
      case OFButtonType.success:
        buttonTextColor = themeValueParser.parseColor(theme.successColorAccent);
        break;
      case OFButtonType.highlight:
        buttonTextColor = themeValueParser.parseColor(theme.primaryTextColor);
        break;
      default:
    }

    return buttonTextColor;
  }

  EdgeInsets _getButtonPaddingForSize(OFButtonSize type) {
    if (padding != null) return padding;

    EdgeInsets buttonPadding;

    switch (size) {
      case OFButtonSize.large:
        buttonPadding = EdgeInsets.symmetric(vertical: 10, horizontal: 20.0);
        break;
      case OFButtonSize.medium:
        buttonPadding = EdgeInsets.symmetric(vertical: 8, horizontal: 12);
        break;
      case OFButtonSize.small:
        buttonPadding = EdgeInsets.symmetric(vertical: 6, horizontal: 10);
        break;
      default:
    }

    return buttonPadding;
  }

  TextStyle _getButtonTextStyleForSize(
      {OFButtonSize size, @required Color color}) {
    TextStyle textStyle;

    switch (size) {
      case OFButtonSize.large:
        textStyle = TextStyle(color: color, fontSize: 16);
        break;
      case OFButtonSize.medium:
      case OFButtonSize.small:
        textStyle = TextStyle(color: color);
        break;
      default:
    }

    return textStyle;
  }

  double _getButtonMinWidthForSize(OFButtonSize type) {
    if (minWidth != null) return minWidth;

    double buttonMinWidth;

    switch (size) {
      case OFButtonSize.large:
      case OFButtonSize.medium:
        buttonMinWidth = 100;
        break;
      case OFButtonSize.small:
        buttonMinWidth = 70;
        break;
      default:
    }

    return buttonMinWidth;
  }
}

enum OFButtonType { primary, success, danger, highlight }

enum OFButtonSize { small, medium, large }
