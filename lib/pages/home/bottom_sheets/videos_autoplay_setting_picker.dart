import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onef/pages/home/bottom_sheets/rounded_bottom_sheet.dart';
import 'package:onef/provider.dart';
import 'package:onef/services/user_preferences.dart';
import 'package:onef/widgets/theming/text.dart';

class OFVideosAutoPlaySettingPickerBottomSheet extends StatefulWidget {
  final ValueChanged<VideosAutoPlaySetting> onTypeChanged;

  final VideosAutoPlaySetting initialValue;

  const OFVideosAutoPlaySettingPickerBottomSheet(
      {Key key, @required this.onTypeChanged, this.initialValue})
      : super(key: key);

  @override
  OFVideosAutoPlaySettingPickerBottomSheetState createState() {
    return OFVideosAutoPlaySettingPickerBottomSheetState();
  }
}

class OFVideosAutoPlaySettingPickerBottomSheetState
    extends State<OFVideosAutoPlaySettingPickerBottomSheet> {
  FixedExtentScrollController _cupertinoPickerController;
  List<VideosAutoPlaySetting> allVideosAutoPlaySettings;

  @override
  void initState() {
    super.initState();
    allVideosAutoPlaySettings = VideosAutoPlaySetting.values();
    _cupertinoPickerController = FixedExtentScrollController(
        initialItem: widget.initialValue != null
            ? allVideosAutoPlaySettings.indexOf(widget.initialValue)
            : null);
  }

  @override
  Widget build(BuildContext context) {
    var provider = OneFProvider.of(context);

    Map<VideosAutoPlaySetting, String> localizationMap = provider
        .userPreferencesService
        .getVideosAutoPlaySettingLocalizationMap();

    return OFRoundedBottomSheet(
      child: SizedBox(
        height: 216,
        child: CupertinoPicker(
          scrollController: _cupertinoPickerController,
          backgroundColor: Colors.transparent,
          onSelectedItemChanged: (int index) {
            VideosAutoPlaySetting newType = allVideosAutoPlaySettings[index];
            widget.onTypeChanged(newType);
          },
          itemExtent: 32,
          children:
              allVideosAutoPlaySettings.map((VideosAutoPlaySetting setting) {
            return OFText(localizationMap[setting]);
          }).toList(),
        ),
      ),
    );
  }
}
