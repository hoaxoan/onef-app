import 'package:flutter/material.dart';
import 'package:onef/models/theme.dart';
import 'package:onef/provider.dart';

class OFAlert extends StatefulWidget {
  final Widget child;
  final double height;
  final double width;
  final EdgeInsets padding;
  final BorderRadiusGeometry borderRadius;
  final Color color;

  const OFAlert(
      {Key key,
      this.child,
      this.height,
      this.width,
      this.padding,
      this.borderRadius,
      this.color})
      : super(key: key);

  @override
  OFAlertState createState() {
    return OFAlertState();
  }
}

class OFAlertState extends State<OFAlert> {
  bool isVisible;

  @override
  void initState() {
    super.initState();
    isVisible = true;
  }

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);
    var themeService = provider.themeService;
    var themeValueParserService = provider.themeValueParserService;

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OFTheme> snapshot) {
          var theme = snapshot.data;
          var primaryColor =
              themeValueParserService.parseColor(theme.primaryColor);
          final bool isDarkPrimaryColor =
              primaryColor.computeLuminance() < 0.179;

          return Container(
            padding: widget.padding ?? EdgeInsets.all(15),
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
                color: isDarkPrimaryColor
                    ? Color.fromARGB(20, 255, 255, 255)
                    : Color.fromARGB(10, 0, 0, 0),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(10)),
            child: widget.child,
          );
        });
  }
}
