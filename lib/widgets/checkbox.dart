import 'package:flutter/material.dart';
import 'package:onef/widgets/icon.dart';

class OFCheckbox extends StatelessWidget {
  final bool value;
  final OBCheckboxSize size;

  const OFCheckbox({
    Key key,
    this.value,
    this.size = OBCheckboxSize.medium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: DecoratedBox(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
        child: Center(
          child: OFIcon(
            value ? OFIcons.checkCircleSelected : OFIcons.checkCircle,
            customSize: 30,
            themeColor: value
                ? OFIconThemeColor.primaryAccent
                : OFIconThemeColor.secondaryText,
          ),
        ),
      ),
    );
  }
}

enum OBCheckboxSize { medium }
