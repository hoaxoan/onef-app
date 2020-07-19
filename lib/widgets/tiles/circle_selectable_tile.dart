import 'package:flutter/material.dart';
import 'package:onef/libs/util/pretty_count.dart';
import 'package:onef/models/circle.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/widgets/circle_color_preview.dart';
import 'package:onef/widgets/fields/checkbox_field.dart';

class OFCircleSelectableTile extends StatelessWidget {
  final Circle circle;
  final OnCirclePressed onCirclePressed;
  final bool isSelected;
  final bool isDisabled;

  const OFCircleSelectableTile(this.circle,
      {Key key, this.onCirclePressed, this.isSelected, this.isDisabled = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int usersCount = circle.usersCount;
    LocalizationService localizationService = OneFProvider.of(context).localizationService;
    String prettyCount =  getPrettyCount(usersCount, localizationService);
    return OFCheckboxField(
      isDisabled: isDisabled,
      value: isSelected,
      title: circle.name,
      subtitle:
          usersCount != null ? localizationService.user__circle_peoples_count(prettyCount) : null,
      onTap: () {
        onCirclePressed(circle);
      },
      leading: SizedBox(
        height: 40,
        width: 40,
        child: Center(
          child: OFCircleColorPreview(
            circle,
            size: OFCircleColorPreviewSize.small,
          ),
        ),
      ),
    );
  }
}

typedef void OnCirclePressed(Circle pressedCircle);
