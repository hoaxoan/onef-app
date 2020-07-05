import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/widgets/checkbox.dart';
import 'package:onef/widgets/theming/text.dart';

class OFCheckboxField extends StatelessWidget {
  final bool value;
  final VoidCallback onTap;
  final Widget leading;
  final String title;
  final String subtitle;
  final bool isDisabled;
  final TextStyle titleStyle;

  OFCheckboxField(
      {@required this.value,
      this.subtitle,
      this.onTap,
      this.leading,
      @required this.title,
      this.isDisabled = false,
      this.titleStyle});

  @override
  Widget build(BuildContext context) {
    TextStyle finalTitleStyle = TextStyle(fontWeight: FontWeight.bold);
    if (titleStyle != null) finalTitleStyle = finalTitleStyle.merge(titleStyle);

    Widget field = MergeSemantics(
      child: ListTile(
          selected: value,
          leading: leading,
          title: OFText(
            title,
            style: finalTitleStyle,
          ),
          subtitle: subtitle != null ? OFText(subtitle) : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              OFCheckbox(
                value: value,
              )
            ],
          ),
          onTap: () {
            if (!isDisabled && onTap != null) onTap();
          }),
    );

    if (isDisabled) {
      field = Opacity(
        opacity: 0.5,
        child: field,
      );
    }
    return field;
  }
}
