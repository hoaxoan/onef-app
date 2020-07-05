import 'package:flutter/material.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/localization.dart';
import 'package:onef/widgets/icon.dart';
import 'package:onef/widgets/theming/secondary_text.dart';

class OFSeeAllButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String resourceName;
  final int previewedResourcesCount;
  final int resourcesCount;

  const OFSeeAllButton(
      {Key key,
      @required this.onPressed,
      @required this.resourceName,
      @required this.previewedResourcesCount,
      @required this.resourcesCount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int remainingResourcesToDisplay = resourcesCount - previewedResourcesCount;
    LocalizationService _localizationService =
        OneFProvider.of(context).localizationService;

    if (previewedResourcesCount == 0 || remainingResourcesToDisplay <= 0)
      return const SizedBox();

    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OFSecondaryText(
              _localizationService.moderation__reports_see_all(
                  resourcesCount, resourceName),
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(
              width: 5,
            ),
            OFIcon(OFIcons.seeMore, themeColor: OFIconThemeColor.secondaryText)
          ],
        ),
      ),
    );
  }
}
