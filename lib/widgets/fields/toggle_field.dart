import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/widgets/theming/divider.dart';
import 'package:onef/widgets/theming/text.dart';

class OFToggleField extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTap;
  final Widget leading;
  final String title;
  final Widget subtitle;
  final bool hasDivider;

  const OFToggleField(
      {Key key,
      @required this.value,
      this.onChanged,
      this.onTap,
      this.leading,
      @required this.title,
      this.subtitle,
      this.hasDivider = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        MergeSemantics(
          child: ListTile(
              leading: leading,
              title: OFText(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: subtitle,
              trailing: CupertinoSwitch(
                value: value,
                onChanged: onChanged,
              ),
              onTap: onTap),
        ),
        hasDivider ? OFDivider() : const SizedBox()
      ],
    );
  }
}
